module Spiral (Model, init, modelSignal, view, main) where

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
                   , points : List Point
                   , t : Float}

numPoints = 1000 -- resolution of the spirals
spirals = 10
distortion = 10 -- the max distortion length in pixels

genPoints : (Int, Int) -> List Point
genPoints (w, h) =
  let windowDiag = (sqrt <| (toFloat w) ^ 2 + (toFloat h) ^ 2) / 2 in
  List.map (\n -> let p = n/numPoints
                      r = p * 2 * spirals * pi
                      scale = p*windowDiag
                  in
                    (scale * cos r, scale * sin r)) [0..numPoints]

init : Model
init = { mouse = (-1, 1)
       , w = 0
       , h = 0
       , targetPoints = []
       , points = []
       , t = 0
       }

background model = filled white <| rect (toFloat model.w) (toFloat model.h)

spiral model = traced (solid black) <| path model.points

connection a b = traced (solid <| black) <| segment a b

-- numToDrop = floor <| (toFloat numPoints) / (toFloat spirals)
numToDrop = 10 -- floor <| (toFloat numPoints) / distortion
view : Model -> Element
view model = collage model.w model.h <| [ background model
                                        , spiral model
                                        , group <| List.map2 connection model.points <| List.drop (numToDrop)  model.points
                                        ]

type Action = WindowDim (Int, Int) | MouseMove Point | NoOp

warpDist model d = -1 - (2 + 1 * sin (d * 0.1 *  model.t / 1000)) -- is also interesting

distortVector model (mx, my) (bx, by) =
  let dx = mx - bx
      dy = my - by
      d = max 1 <| sqrt <| dx^2 + dy^2
      (nx, ny) = (dx / d, dy / d)
      distortionAmnt = distortion * (warpDist model d)
  in (nx * distortionAmnt, ny * distortionAmnt)

addP (a, b) (c, d) = (a + c, b + d)

distortPoint : Model -> Point -> Point
distortPoint model point = addP point (distortVector model model.mouse point)

distort : Model -> List Point -> List Point
distort model ps = List.map (distortPoint model) ps

update : Action -> Model -> Model
update action model =
  case action of
    NoOp             -> model
    WindowDim (w, h) -> let ps = genPoints (w, h) in
                        { model | w <- w
                                , h <- h
                                , targetPoints <- ps
                                , points <- distort model ps }
    MouseMove mouse  -> { model | mouse <- transformMouse model mouse
                                , points <- distort model model.targetPoints
                                , t <- model.t + 1}

windowDims = Signal.map (WindowDim) Window.dimensions

intPair2FloatPair (x, y) = (toFloat x, toFloat y)

mousePos = Signal.map (MouseMove << intPair2FloatPair) <| Signal.sampleOn (Time.fps 30) Mouse.position

transformMouse : Model -> Point -> Point
transformMouse model (mx, my) =
  (mx - (toFloat model.w) / 2, -my + (toFloat model.h) / 2)

modelSignal : Signal Model
modelSignal =
  foldp' update (\a -> update a init)  <| Signal.merge windowDims mousePos

main : Signal Element
main = Signal.map view modelSignal
