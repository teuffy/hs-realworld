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
type LoginResponse = (Headers '[Header "Access-Control-Allow-Origin" Text] LoginResponseModel)
type UserHandler = Get '[JSON] UserResponse
type UserResponse = (Headers '[Header "Access-Control-Allow-Origin" Text] UserResponseModel)

type API =
    "api-not-implemented-yet" :> "user" :> Header "Authorization" Text :> UserHandler
    :<|> "api" :> "users" :> "login" :> ReqBody '[JSON] LoginRequestModel :> LoginHandler
    :<|> "static" :> Raw
