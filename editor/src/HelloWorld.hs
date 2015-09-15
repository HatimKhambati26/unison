{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}

module Main where

import Control.Monad
import Reflex
import Reflex.Dom
import Unison.Term
import Unison.Type (defaultSymbol)
import Unison.Dimensions (Width(..),X(..),Y(..))
import qualified Unison.Doc as Doc
import qualified Unison.DocView as DocView
import qualified Reflex.Dynamic as Dynamic
import Unison.UI (mouseMove')

term = var' "foo" `app`
       vector (map num [0..5]) `app`
       var' "bar" `app`
       (var' "baz" `app` num 42)

termDoc = view defaultSymbol term

main :: IO ()
main = mainWidget $ mdo
  el "pre" $ do
    text "mouse: "
    display mouse
  el "pre" $ do
    text "path: "
    display path
    pure ()
  el "pre" $ do
    text "region: "
    display region
  (body, (mouse,path,region)) <- el' "div" $ do
    (e,d,(w,h)) <- DocView.widget (Width 300) termDoc
    mouse <- mouseMove' e >>= holdDyn (X 0, Y 0)
    path  <- mapDyn (Doc.at d) mouse
    region <- mapDyn (Doc.region d) path
    sel <- mapDyn (DocView.selectionLayer h) region
    _ <- widgetHold (pure ()) (Dynamic.updated sel)
    return (mouse, path, region)
  return ()

