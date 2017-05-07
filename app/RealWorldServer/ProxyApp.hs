{-# LANGUAGE OverloadedStrings #-}

module RealWorldServer.ProxyApp (proxyApp) where

import           Network.HTTP.Client (Manager)
import           Network.HTTP.ReverseProxy
import           Network.Wai
import           RealWorldServer.Types

forwardRequest :: Config -> Request -> IO WaiProxyResponse
forwardRequest (Config _ proxiedPort _) _ = pure (WPRProxyDest (ProxyDest "127.0.0.1" proxiedPort))

proxyApp :: Config -> Manager -> Application
proxyApp config manager = waiProxyTo (forwardRequest config) defaultOnExc manager
