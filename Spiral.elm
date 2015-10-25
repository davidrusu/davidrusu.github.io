module Spiral (Model, init, modelSignal, view) where

import Graphics.Collage exposing (..)
import Graphics.Element exposing (Element)
import Color exposing (..)
import Mouse
import Time

type alias Point = (Float, Float)
type alias Model = { mouse : Point
                   , targetPoints : List Point
                   , points : List Point }

w = 400
h = 400

numPoints = 1000 -- resolution of the spirals
spirals = 10
distortion = 50 -- the max distortion length in pixels

genPoints = List.map (\n -> let p = n/numPoints
                                r = p * 2 * spirals * pi
                                scale = p * (sqrt <| w ^ 2 + h ^ 2) / 2
                            in (scale * cos r, scale * sin r)) [0..numPoints]

init : Model
init = { mouse = (0, 0)
       , targetPoints = genPoints
       , points = genPoints
       }

viewPoint : Point -> Form
viewPoint point = move point (filled black (circle 1))

view : Model -> Element
view model = collage w h <| [ filled white (rect w h)
                            , move model.mouse (filled Color.black (circle 10))
                            , traced (solid black) <| path model.points
                            ] 
                   
type Action = MouseMove Point | NoOp

distortVector (mx, my) (bx, by) = let d = sqrt <| (mx-bx)^2 + (my-by)^2
                                  in ((mx - bx) / d * 50, (my - by) / d * 50)

addP (a, b) (c, d) = (a + c, b + d)

distortPoint : Model -> Point -> Point
distortPoint model p = addP p (distortVector model.mouse p)

update : Action -> Model -> Model
update action model = case action of
                        NoOp            -> model
                        MouseMove mouse -> { model | mouse <- mouse
                                                   , points <- List.map (distortPoint model) model.targetPoints}

transformMouse : (Int, Int) -> Action
transformMouse (mx, my) = MouseMove (toFloat mx - (w / 2), -(toFloat my) + (h/2))

modelSignal : Signal Model
modelSignal = Signal.foldp update init <| Signal.map transformMouse Mouse.position

main = Signal.map view modelSignal
