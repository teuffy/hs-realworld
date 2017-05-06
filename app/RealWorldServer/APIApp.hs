module RealWorldServer.APIApp (runApp) where

import           Control.Monad.Except
import           Network.Wai
import           Network.Wai.Handler.Warp
import           Network.Wai.Logger
import           RealWorld
import           RealWorldServer.API
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

apiProxy :: Proxy API
apiProxy = Proxy

apiApp :: AppState -> ApacheLogger -> Application
apiApp state logger = serve apiProxy (server state logger)

runApp :: Config -> AppState -> IO ()
runApp (Config port) state = withStdoutLogger $ \logger -> do
    let settings = setPort port $ setLogger logger defaultSettings
    runSettings settings (apiApp state logger)
