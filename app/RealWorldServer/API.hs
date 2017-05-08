{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module RealWorldServer.API
    ( API
    , APIResponse
    , LoginResponse
    , UserResponse
    ) where

import           Control.Monad.Except
import           Data.Text
import           RealWorldServer.Login
import           RealWorldServer.User
import           Servant

type APIResponse a = ExceptT ServantErr IO a
type LoginHandler = Post '[JSON] LoginResponse
type LoginResponse = LoginResponseModel
type UserHandler = Get '[JSON] UserResponse
type UserResponse = UserResponseModel

type API =
    "api" :> "user" :> Header "Authorization" Text :> UserHandler
    :<|> "api" :> "users" :> "login" :> ReqBody '[JSON] LoginRequestModel :> LoginHandler
    :<|> "static" :> Raw
