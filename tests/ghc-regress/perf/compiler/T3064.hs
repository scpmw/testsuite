{-# LANGUAGE Rank2Types, TypeSynonymInstances, FlexibleInstances #-}
{-# LANGUAGE TypeFamilies, GeneralizedNewtypeDeriving #-}
module Bug2 where

newtype ReaderT r m a = ReaderT { runReaderT :: r -> m a }

instance (Monad m) => Monad (ReaderT r m) where
    return a = ReaderT $ \_ -> return a
    m >>= k  = ReaderT $ \r -> do
        a <- runReaderT m r
        runReaderT (k a) r
    fail msg = ReaderT $ \_ -> fail msg

newtype ResourceT r s m v = ResourceT { unResourceT :: ReaderT r m v }
  deriving (Monad)

data Ctx = Ctx

data Ch = Ch

type CAT s c = ResourceT [Ch] (s,c)

type CtxM c = ResourceT Ctx c IO

newtype CA s c v = CA { unCA :: CAT s c (CtxM c) v }
  deriving (Monad)

class (Monad m) => MonadCA m where
  type CtxLabel m

instance MonadCA (CA s c) where
  type CtxLabel (CA s c) = c

instance (Monad m, MonadCA m, c ~ CtxLabel m) => MonadCA  (CAT s c m) where
  type CtxLabel (CAT s c m) = c

runCAT :: (forall s. CAT s c m v) -> m v
runCAT action = runReaderT (unResourceT action) []

newRgn :: MonadCA m => (forall s. CAT s (CtxLabel m) m v) -> m v
newRgn = runCAT

runCA :: (forall s c. CA s c v) -> IO v
runCA action = runCtxM (runCAT (unCA action))

runCtxM :: (forall c. CtxM c v) -> IO v
runCtxM action = runReaderT (unResourceT action) Ctx

-- test11 :: IO ()
-- test11 = runCA(newRgn(newRgn(newRgn(newRgn(newRgn(
--   newRgn(newRgn(newRgn(newRgn(return()))))))))))

-- test12 :: IO ()
-- test12 = runCA(newRgn(newRgn(newRgn(newRgn(newRgn(newRgn(
--   newRgn(newRgn(newRgn(newRgn(return())))))))))))

-- test13 :: IO ()
-- test13 = runCA(newRgn(newRgn(newRgn(newRgn(newRgn(newRgn(newRgn(
--   newRgn(newRgn(newRgn(newRgn(return()))))))))))))

test14 :: IO ()
test14 = runCA(newRgn(newRgn(newRgn(newRgn(newRgn(newRgn(newRgn(newRgn(
  newRgn(newRgn(newRgn(newRgn(return())))))))))))))
