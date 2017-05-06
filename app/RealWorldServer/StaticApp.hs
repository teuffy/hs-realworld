{-# LANGUAGE OverloadedStrings #-}

module RealWorldServer.StaticApp (staticApp) where

import           Network.HTTP.Types
import           Network.Wai
import           Network.Wai.Logger

staticApp :: ApacheLogger -> Application
staticApp _ _ respond = respond $ responseLBS status200 headers "Hello world"
    where
        headers = [("Content-Type", "text/plain")]
