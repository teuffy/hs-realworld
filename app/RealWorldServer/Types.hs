module RealWorldServer.Types
    ( Command (..)
    , Config (..)
    ) where

import           Network.Wai.Handler.Warp

data Command = ServerCommand Config | VersionCommand

data Config = Config Port Port
