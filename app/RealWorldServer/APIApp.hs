{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module RealWorldServer.APIApp (runApp) where

import           Control.Monad.Except
import           Data.Aeson
import qualified Data.Map as Map
import           Data.Text (Text)
import qualified Data.Text as Text
import           Database.MongoDB hiding (String)
import           Network.HTTP.Client (Manager, defaultManagerSettings, newManager)
import           Network.Wai hiding (responseStatus)
import           Network.Wai.Handler.Warp
import           Network.Wai.Logger
import           RealWorld
import           RealWorldServer.API
import           RealWorldServer.DB
import           RealWorldServer.Login
import           RealWorldServer.ProxyApp
import           RealWorldServer.StaticApp
import           RealWorldServer.Types
import           RealWorldServer.User
import           Servant
import qualified Web.JWT as JWT

secret :: JWT.Secret
secret = JWT.secret "secret"

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

server :: ApacheLogger -> Server API
server logger =
    userHandler
    :<|> loginHandler
    :<|> staticApp logger

userHandler :: Maybe Text -> APIResponse UserResponse
userHandler mbToken = do
    case authToken mbToken of
        Nothing -> throwError err401
        Just token -> do
            -- TODO: Validate token

            -- TODO: Extract object ID etc.
            let Just objId = parseObjectId "xxx"

            mbUser <- liftIO $ withConduitDB (findUser objId)
            case mbUser of
                Nothing -> throwError err401
                Just (UserModel _ userName email) ->
                    return $ addHeader "*" (UserResponseModel userName email token)

loginHandler :: LoginRequestModel -> APIResponse LoginResponse
loginHandler (LoginRequestModel email _) = do
    mbUser <- liftIO $ withConduitDB (findUser email)
    case mbUser of
        Nothing -> throwError err401
        Just user -> return $ addHeader "*" (mkResponseModel user)
    where
        mkResponseModel user@(UserModel _ userName_ email_) =
            LoginResponseModel userName_ email_ (mkAuthToken user)
        mkAuthToken (UserModel objId_ userName_ _) = Token $ JWT.encodeSigned JWT.HS256 secret JWT.def
            { JWT.unregisteredClaims = Map.fromList
                [ ("id", String (objectIdText objId_))
                , ("username", String (unUserName userName_))
                ]
            }

apiProxy :: Proxy (API :<|> Raw)
apiProxy = Proxy

apiApp :: Config -> ApacheLogger -> Manager -> Application
apiApp config logger manager = serve apiProxy
    (server logger :<|> proxyApp config manager)

runApp :: Config -> IO ()
runApp config@(Config port _) = withStdoutLogger $ \logger -> do
    let settings = setPort port $ setLogger logger defaultSettings
    manager <- newManager defaultManagerSettings
    runSettings settings (apiApp config logger manager)
