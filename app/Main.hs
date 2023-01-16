{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE KindSignatures #-}
module Main where
import Data.Aeson
import GHC.Generics
import GHC.TypeLits
import Network.Wai.Handler.Warp
import Servant
import Network.Wai.Middleware.RequestLogger
import Control.Monad.IO.Class
import Data.Time (getCurrentTime)
import Data.Time.Format.ISO8601 (iso8601Show)

type Api = ReqBody '[JSON] Value :> Post '[JSON] String

handler :: Value -> Handler String
handler x = do
  liftIO $ putStrLn $ show x
  now <- liftIO getCurrentTime
  liftIO $ putStrLn $ ("\n====== " <> iso8601Show now <> ":\n" <> show x)
  liftIO $ writeFile ("logs/"<> iso8601Show now) (show x)
  pure ("\n====== " <> iso8601Show now <> ":\n" <> show x)


server :: Server Api
server = handler

api :: Proxy Api
api = Proxy

main :: IO ()
main = do
  warpLogger <- mkRequestLogger $ defaultRequestLoggerSettings {outputFormat = Detailed True}
  runSettings (setPort 8000 $ defaultSettings) $ warpLogger $ serve (Proxy :: Proxy Api) server




