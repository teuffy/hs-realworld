{-# LANGUAGE OverloadedStrings #-}

module RealWorldServer.User
    ( UserResponseModel (..)
    ) where

import           Data.Aeson
import           RealWorld

data UserResponseModel = UserResponseModel UserName Email Token

instance ToJSON UserResponseModel where
    toJSON (UserResponseModel name email token) = object
        [ "username" .= unUserName name
        , "email" .= unEmail email
        , "token" .= unToken token
        ]
