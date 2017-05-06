{-# LANGUAGE OverloadedStrings #-}

module RealWorld
    ( AppState (..)
    , User (..)
    ) where

import           Data.Aeson

data User = User String String

data AppState = AppState [User]

instance ToJSON User where
    toJSON (User name email) = object
        [ "username" .= name
        , "email" .= email
        , "token" .= token
        ]

token :: String
token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjU5MGUyMzNiN2RlYTA4NDFhMDZjMmVjNyIsInVzZXJuYW1lIjoiZ3Vlc3QiLCJleHAiOjE0OTkyOTM2NDgsImlhdCI6MTQ5NDEwOTY0OH0.QYYhgkXwKPv26bAF1UNCH7c9cjXZ1y4Cvl-Ux_4SCqs"
