{-# LANGUAGE TypeOperators #-}

module RealWorldServer.APIApp (runApp) where

import           Control.Monad.Except
import           Network.HTTP.Client (Manager, defaultManagerSettings, newManager)
import           Network.Wai
import           Network.Wai.Handler.Warp
import           Network.Wai.Logger
import           RealWorld
import           RealWorldServer.API
import           RealWorldServer.ProxyApp
import           RealWorldServer.StaticApp
import           RealWorldServer.Types
import           Servant

userServer :: AppState -> ExceptT ServantErr IO User
userServer (AppState (user : _)) = return user
userServer (AppState _) = throwError err404

server :: AppState -> ApacheLogger -> Server API
server state@(AppState users) logger =
    userServer state
    :<|> return users
    :<|> staticApp logger

apiProxy :: Proxy (API :<|> Raw)
apiProxy = Proxy

apiApp :: Config -> AppState -> ApacheLogger -> Manager -> Application
apiApp config state logger manager = serve apiProxy
    (server state logger :<|> proxyApp config manager)

runApp :: Config -> AppState -> IO ()
runApp config@(Config port _) state = withStdoutLogger $ \logger -> do
    let settings = setPort port $ setLogger logger defaultSettings
    manager <- newManager defaultManagerSettings
    runSettings settings (apiApp config state logger manager)
