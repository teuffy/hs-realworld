module Main (main) where

import           System.FilePath.Glob
import           Test.DocTest

compilerOpts :: [String]
compilerOpts = []

defaultIncludeDirs :: [FilePath]
defaultIncludeDirs = []

doctestWithIncludeDirs :: [FilePath] -> IO ()
doctestWithIncludeDirs fs = doctest (map ("-I" ++) defaultIncludeDirs ++ fs ++ compilerOpts)

sourceDirs :: [FilePath]
sourceDirs = ["app", "src"]

main :: IO ()
main = mconcat (map (glob . (++ "/**/*.hs")) sourceDirs) >>= doctestWithIncludeDirs
