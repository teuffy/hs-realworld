{-# LANGUAGE OverloadedStrings #-}

module RealWorldServer.AuthToken
    ( decodeAuthToken
    ) where

import           Data.Aeson
import           Data.Text
import qualified Data.Map as Map
import           Database.MongoDB hiding (String, Value)
import           RealWorld
import           RealWorldServer.DB
import           Web.JWT

decodeString :: Value -> Maybe Text
decodeString (String x) = Just x
decodeString _ = Nothing

decodeAuthToken :: Secret -> Token -> Maybe (ObjectId, Text)
decodeAuthToken secret (Token t) = do
    jwt <- decodeAndVerifySignature secret t
    let m = unregisteredClaims $ claims jwt
    objIdTextValue <- Map.lookup "id" m
    objIdText <- decodeString objIdTextValue
    objId <- parseObjectId objIdText
    userNameValue <- Map.lookup "username" m
    userName <- decodeString userNameValue
    return $ (objId, userName)
