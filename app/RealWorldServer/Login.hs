{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module RealWorldServer.Login
    ( LoginRequestModel (..)
    , LoginResponseModel (..)
    ) where

import           Data.Aeson
import           RealWorld

data LoginRequestModel = LoginRequestModel Email Password
data LoginResponseModel = LoginResponseModel UserName Email Token

instance FromJSON LoginRequestModel where
    parseJSON = withObject "LoginRequestModel" $ \o -> do
        user <- o .: "user"
        email <- Email <$> user .: "email"
        password <- Password <$> user .: "password"
        return $ LoginRequestModel email password

instance ToJSON LoginResponseModel where
    toJSON (LoginResponseModel userName email token) = object
        [ "user" .= object
            [ "username" .= unUserName userName
            , "email" .= unEmail email
            , "token" .= unToken token
            ]
        ]
