module RealWorld.Types
    ( Email (..)
    , Password (..)
    , Token (..)
    , UserName (..)
    ) where

import           Data.Text

newtype Email = Email { unEmail :: String }
newtype Password = Password { unPassword :: String }
newtype Token = Token { unToken :: Text }
newtype UserName = UserName { unUserName :: Text }
