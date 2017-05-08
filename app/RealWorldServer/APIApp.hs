{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module RealWorldServer.APIApp (runApp) where

import           Control.Monad.Except
import           Data.Text (Text)
import qualified Data.Text as Text
import           Database.MongoDB hiding (String, Value)
import           Network.HTTP.Client (Manager, defaultManagerSettings, newManager)
import           Network.HTTP.Types
import           Network.Wai
import           Network.Wai.Handler.Warp
import           Network.Wai.Logger
import           RealWorld
import           RealWorldServer.API
import           RealWorldServer.AuthToken
import           RealWorldServer.DB
import           RealWorldServer.Login
import           RealWorldServer.ProxyApp
import           RealWorldServer.StaticApp
import           RealWorldServer.Types
import           RealWorldServer.User
import           Servant

authToken :: Maybe Text -> Maybe Token
authToken (Just s) = Token <$>
    case removeTokenPrefix "Token" s of
        Nothing -> removeTokenPrefix "Bearer" s
        result -> result
    where
        removeTokenPrefix prefix = removePrefix (prefix `Text.append` " ")
authToken _ = Nothing

withConduitDB :: Action IO a -> IO a
withConduitDB = withCollection "conduit"

server :: Config -> ApacheLogger -> Server API
server config logger =
    userHandler config
    :<|> loginHandler config
    :<|> staticApp logger

userHandler :: Config -> Maybe Text -> APIResponse UserResponse
userHandler (Config _ _ secret) mbToken = do
    case authToken mbToken of
        Nothing -> throwError err401
        Just token -> do
            case decodeAuthToken secret token of
                Nothing -> throwError err401
                Just (objId, _) -> do
                    liftIO $ print objId
                    mbUser <- liftIO $ withConduitDB (findUser objId)
                    case mbUser of
                        Nothing -> throwError err401
                        Just (UserModel _ userName email) ->
                            return $ UserResponseModel userName email token

loginHandler :: Config -> LoginRequestModel -> APIResponse LoginResponse
loginHandler (Config _ _ secret) (LoginRequestModel email _) = do
    mbUser <- liftIO $ withConduitDB (findUser email)
    case mbUser of
        Nothing -> throwError err401
        Just user -> return $ mkResponseModel user
    where
        mkResponseModel (UserModel objId_ userName_ email_) =
            LoginResponseModel userName_ email_ (encodeAuthToken secret (objId_, userName_))

apiProxy :: Proxy (API :<|> Raw)
apiProxy = Proxy

apiApp :: Config -> ApacheLogger -> Manager -> Application
apiApp config logger manager = serve apiProxy
    (server config logger :<|> proxyApp config manager)

runApp :: Config -> IO ()
runApp config@(Config port _ _) = withStdoutLogger $ \logger -> do
    let settings = setPort port $ setLogger logger defaultSettings
    manager <- newManager defaultManagerSettings
    runSettings settings (cors $ apiApp config logger manager)

cors :: Middleware
cors app req = (case pathInfo req of
    ["api", "user"] -> modifyResponse addCorsHeaders
    ["api", "users", "login"] -> modifyResponse addCorsHeaders
    _ -> id) app req

addCorsHeaders :: Response -> Response
addCorsHeaders resp
    | responseStatus resp == status200 = mapResponseHeaders (("Access-Control-Allow-Origin", "*") :) resp
    | otherwise = resp
