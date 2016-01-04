module Header (Model, init, Action, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)

type alias Path = String

type alias Model = { home : (String, Path)
                   , nav : List (String, Path)
                   , selected : Int }

basePath = "https://davidrusu.github.io"
projectsPath = basePath ++ "pages//projects.html"
statsPath = "http://davidrusu.github.io/mastery/" -- basePath ++ "/stats.html"
teasPath = basePath ++ "/pages/tea_log.html"

init = create 
         ("David Rusu", basePath)
         [ ("Projects", projectsPath)
         , ("Stats", statsPath)
         , ("Tea Log", teasPath) ] -1

                 
create : (String, Path) -> List (String, Path) -> Int -> Model
create home nav selected = { home = home
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

