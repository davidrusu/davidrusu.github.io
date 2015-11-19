module Utils (css) where

import Html exposing (..)
import Html.Attributes exposing (..)

css path = node "link" [ rel "stylesheet", href path ] []
      
