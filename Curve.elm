module Curve (Model, init, modelSignal, view, main) where

import Graphics.Collage exposing (..)
import Graphics.Element exposing (Element)
import Color exposing (..)
import Mouse
import Window
import Time
import Signal.Extra exposing (foldp')

type alias Point = (Float, Float)
type alias Model = { mouse : Point
                   , w : Int
                   , h : Int
                   , targetPoints : List Point
                   , points : List Point }

numPoints = 500 -- resolution of points
distortion = 50 -- the max distortion length in pixels

genPoints : (Int, Int) -> List Point
genPoints (w, h) =
  let windowDiag = (sqrt <| (toFloat w) ^ 2 + (toFloat h) ^ 2) / 2 in
  List.map (\n -> let p = n/numPoints
                      scale = p*windowDiag
                  in
                    (-windowDiag / 2 + scale, 0 ))
        [0..numPoints]

init : Model
init = { mouse = (0, 100)
       , w = 0
       , h = 0
       , targetPoints = []
       , points = []
       }

background model = filled white <| rect (toFloat model.w) (toFloat model.h)

curve model = traced (solid black) <| path model.points

connection a b = traced (solid <| rgba 0 0 0 1) <| segment a b

numToDrop = floor <| (toFloat numPoints) / distortion * 4
view : Model -> Element
view model = collage model.w model.h <| [ background model
                                        , group <| List.map2 connection model.points <| List.drop (numToDrop)  model.points
                                        ]

type Action = WindowDim (Int, Int) | MouseMove Point | NoOp

warpDist d = -1 -- logBase 2 d -- is also interesting

distortVector (mx, my) (bx, by) =
  let dx = mx - bx
      dy = my - by
      d = max 1 <| sqrt <| dx^2 + dy^2
      (nx, ny) = (dx / d, dy / d)
      distortionAmnt = distortion * warpDist d
  in (nx * distortionAmnt, ny * distortionAmnt)

addP (a, b) (c, d) = (a + c, b + d)
scaleP s (a, b) = (s * a, s * b)

distortPoint : Model -> Point -> Point
distortPoint model point = addP point (distortVector model.mouse point)

distort : Model -> List Point -> List Point
distort model ps = List.map (distortPoint model) ps

update : Action -> Model -> Model
update action model =
  case action of
    NoOp             -> model
    WindowDim (w, h) -> let ps = genPoints (w, h) in
                        { model | w = w
                                , h = h
                                , targetPoints = ps
                                , points = distort model ps }
    MouseMove mouse  -> { model | mouse =  addP model.mouse <| scaleP 1 <| (transformMouse model mouse) `addP` (scaleP -1 model.mouse)
                                , points = distort model model.targetPoints }

windowDims = Signal.map (WindowDim) Window.dimensions

intPair2FloatPair (x, y) = (toFloat x, toFloat y)

mousePos = Signal.map (MouseMove << intPair2FloatPair) Mouse.position

transformMouse : Model -> Point -> Point
transformMouse model (mx, my) =
  (mx - (toFloat model.w) / 2, -my + (toFloat model.h) / 2)

modelSignal : Signal Model
modelSignal =
  foldp' update (\a -> update a init)  <| Signal.merge windowDims mousePos

main : Signal Element
main = Signal.map view modelSignal
