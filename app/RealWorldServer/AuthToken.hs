{-# LANGUAGE OverloadedStrings #-}

module RealWorldServer.AuthToken
    ( decodeAuthToken
    , encodeAuthToken
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

decodeAuthToken :: Secret -> Token -> Maybe (ObjectId, UserName)
decodeAuthToken secret_ (Token t) = do
    jwt <- decodeAndVerifySignature secret_ t
    let m = unregisteredClaims $ claims jwt
    objIdTextValue <- Map.lookup "id" m
    objIdText <- decodeString objIdTextValue
    objId <- parseObjectId objIdText
    userNameValue <- Map.lookup "username" m
    userName <- UserName <$> decodeString userNameValue
    return $ (objId, userName)

encodeAuthToken :: Secret -> (ObjectId, UserName) -> Token
encodeAuthToken secret_ (objId, userName) = Token $ encodeSigned HS256 secret_ def
    { unregisteredClaims = Map.fromList
        [ ("id", String (objectIdText objId))
        , ("username", String (unUserName userName))
        ]
    }
