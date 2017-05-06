module Main (main) where

import           RealWorld
import           RealWorldServer

productVersion :: String
productVersion = "Real World in Haskell " ++ fullVersionString

initialState :: AppState
initialState = AppState $
    [ User "guest" "guest@guest.com"
    , User "cdarwin" "cdarwin@evolution.com"
    , User "aeinstein" "aeinstein@relativity.com"
    ]

main :: IO ()
main = parseCommand >>= handleCommand
    where
        handleCommand (ServerCommand config) = runApp config initialState
        handleCommand VersionCommand = putStrLn productVersion
