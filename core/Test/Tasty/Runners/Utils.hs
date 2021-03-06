-- | Note: this module is re-exported as a whole from "Test.Tasty.Runners"
module Test.Tasty.Runners.Utils where

import Control.Exception
import Control.Applicative
import Prelude  -- Silence AMP import warnings
import Text.Printf

-- | Catch possible exceptions that may arise when evaluating a string.
-- For normal (total) strings, this is a no-op.
--
-- This function should be used to display messages generated by the test
-- suite (such as test result descriptions).
--
-- See e.g. <https://github.com/feuerbach/tasty/issues/25>
formatMessage :: String -> IO String
formatMessage = go 3
  where
    -- to avoid infinite recursion, we introduce the recursion limit
    go :: Int -> String -> IO String
    go 0        _ = return "exceptions keep throwing other exceptions!"
    go recLimit msg = do
      mbStr <- try $ evaluate $ forceElements msg
      case mbStr of
        Right () -> return msg
        Left e' -> printf "message threw an exception: %s" <$> go (recLimit-1) (show (e' :: SomeException))

-- https://ro-che.info/articles/2015-05-28-force-list
forceElements :: [a] -> ()
forceElements = foldr seq ()
