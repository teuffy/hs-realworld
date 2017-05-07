module Main (main) where

import           RealWorldServer

productVersion :: String
productVersion = "Real World in Haskell " ++ fullVersionString

main :: IO ()
main = parseCommand >>= handleCommand
    where
        handleCommand (ServerCommand config) = runApp config
        handleCommand VersionCommand = putStrLn productVersion
