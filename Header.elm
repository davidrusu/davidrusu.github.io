module Header (Model, init, Action, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)

type alias Path = String

type alias Model = { home : (String, Path)
                   , nav : List (String, Path)
                   , selected : Int }

init : (String, Path) -> List (String, Path) -> Int -> Model
init home nav selected = { home = home
                         , nav = nav
                         , selected = selected }

type Action = NoOp

navButton : (String, Path) -> Html
navButton (label, url) = div
                           [ class "nav_button" ]
                           [ a [ href url ] [ text label ] ]

viewNav : Model -> List Html
viewNav model = List.map navButton model.nav

view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ class "header" ]
    [ navButton model.home
    , div [ class "nav" ] (viewNav model)
    ]

update : Action -> Model -> Model
update action model = case action of
                        NoOp -> model

