{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module RealWorldServer.API
    ( API
    ) where

import           RealWorld
import           Servant.API

type API =
    "user" :> Get '[JSON] User
    :<|> "users" :> Get '[JSON] [User]
    :<|> "static" :> Raw
