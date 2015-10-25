module TeaLog (Model, init, Action, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)

type alias Model = {}

init = {}

type Action = NoOp

update : Action -> Model -> Model
update action model = case Action of
                        NoOp -> model

view : Signal.Address Action -> Model -> Html
view address model = div [] [text "TEeas!!"]

actionMailbox : Signal.Mailbox Action
actionMailbox = Signal.mailbox NoOp
                     
models = foldp update init actionMailbox.signal

main = map (view actionMailbox.address) models
