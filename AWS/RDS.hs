{-# LANGUAGE FlexibleContexts, RankNTypes #-}

module AWS.RDS
    ( -- * RDS Environment
      RDS
    , runRDS
    , setRegion
      -- * DBInstance
    , module AWS.RDS.DBInstance
    ) where

import Data.Text (Text)
import Data.Conduit
import Control.Monad.Trans.Control (MonadBaseControl)
import Control.Monad.IO.Class (MonadIO)
import qualified Control.Monad.State as State
import qualified Network.HTTP.Conduit as HTTP
import Data.Monoid ((<>))

import AWS.Class
import AWS.Util

import AWS
import AWS.RDS.Internal
import AWS.RDS.DBInstance

initialRDSContext :: HTTP.Manager -> AWSContext
initialRDSContext mgr = AWSContext
    { manager = mgr
    , endpoint = "rds.amazonaws.com"
    , lastRequestId = Nothing
    }

runRDS :: MonadIO m => Credential -> RDS m a -> m a
runRDS = runAWS initialRDSContext

setRegion
    :: (MonadBaseControl IO m, MonadResource m)
    => Text -> RDS m ()
setRegion region = do
    ctx <- State.get
    State.put
        ctx { endpoint =
            "rds." <> textToBS region <> ".amazonaws.com"
            }
