{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module RealWorldServer.APIApp (runApp) where

import           Control.Monad.Except
import           Data.Aeson
import qualified Data.Map as Map
import           Data.Text (Text)
import qualified Data.Text as Text
import           Database.MongoDB hiding (String, Value)
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
                            return $ addHeader "*" (UserResponseModel userName email token)

decodeString :: Value -> Maybe Text
decodeString (String x) = Just x
decodeString _ = Nothing

decodeAuthToken :: JWT.Secret -> Token -> Maybe (ObjectId, Text)
decodeAuthToken secret (Token t) = do
    jwt <- JWT.decodeAndVerifySignature secret t
    let m = JWT.unregisteredClaims $ JWT.claims jwt
    objIdTextValue <- Map.lookup "id" m
    objIdText <- decodeString objIdTextValue
    objId <- parseObjectId objIdText
    userNameValue <- Map.lookup "username" m
    userName <- decodeString userNameValue
    return $ (objId, userName)

loginHandler :: Config -> LoginRequestModel -> APIResponse LoginResponse
loginHandler (Config _ _ secret) (LoginRequestModel email _) = do
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
    (server config logger :<|> proxyApp config manager)

runApp :: Config -> IO ()
runApp config@(Config port _ _) = withStdoutLogger $ \logger -> do
    let settings = setPort port $ setLogger logger defaultSettings
    manager <- newManager defaultManagerSettings
    runSettings settings (apiApp config logger manager)
