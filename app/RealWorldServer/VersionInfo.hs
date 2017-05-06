{-# LANGUAGE TemplateHaskell #-}

module RealWorldServer.VersionInfo (fullVersionString) where

import           Data.Version
import           Distribution.VcsRevision.Git
import           Language.Haskell.TH.Syntax
import           Paths_hs_realworld

gitVersionString :: String
gitVersionString = $(do
    v <- qRunIO getRevision
    lift $ case v of
        Nothing -> []
        Just (commit, True)  -> commit ++ " (locally modified)"
        Just (commit, False) -> commit)

fullVersionString :: String
fullVersionString = case gitVersionString of
    [] -> showVersion version
    v -> showVersion version ++ "." ++ v
