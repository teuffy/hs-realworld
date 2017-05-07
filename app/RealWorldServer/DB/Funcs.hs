{-# LANGUAGE OverloadedStrings #-}

module RealWorldServer.DB.Funcs
    ( findUser
    , objectIdText
    , parseObjectId
    , withCollection
    ) where

import           Control.Exception
import           Data.Text
import           Database.MongoDB
import           RealWorld
import           RealWorldServer.DB.Types
import           Text.Read

findUser :: FindKey a => a -> Action IO (Maybe UserModel)
findUser key = do
    mbDoc <- findOne (select (findKey key) "users")
    return $ mbDoc >>= \doc -> pure $ UserModel
        (at "_id" doc)
        (UserName $ at "username" doc)
        (Email $ at "email" doc)

parseObjectId :: String -> Maybe ObjectId
parseObjectId = readMaybe

objectIdText :: ObjectId -> Text
objectIdText = pack . show

withCollection :: Text -> Action IO a -> IO a
withCollection collectionName action = bracket
    (connect (host "127.0.0.1"))
    close
    (\cx -> access cx master collectionName action)
