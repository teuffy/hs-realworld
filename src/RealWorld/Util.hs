module RealWorld.Util
    ( removePrefix
    ) where

import           Data.Text
import           Prelude hiding (drop, length)

removePrefix :: Text -> Text -> Maybe Text
removePrefix prefix s
    | prefix `isPrefixOf` s = Just (drop (length prefix) s)
    | otherwise = Nothing
