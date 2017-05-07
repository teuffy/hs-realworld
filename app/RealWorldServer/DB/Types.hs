{-# LANGUAGE OverloadedStrings #-}

module RealWorldServer.DB.Types
    ( FindKey (..)
    , UserModel (..)
    ) where

import           Database.MongoDB
import           RealWorld

data UserModel = UserModel ObjectId UserName Email

class FindKey a where
    findKey :: a -> Selector

instance FindKey ObjectId where
    findKey x = ["_id" =: x]

instance FindKey UserName where
    findKey (UserName x) = ["username" =: x]

instance FindKey Email where
    findKey (Email x) = ["email" =: x]
