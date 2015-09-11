import Graphics.Collage exposing (Form, collage, filled, circle, rect, move)
import Color exposing (black, white)
import List exposing (map)

type alias World = { circles : List Circle }

type alias Circle = { pos : Vec, radius : Float, vel : Vec }

type alias Vec = { x : Float, y : Float }

w = 300
h = 300

initWorld : World
initWorld = {
  circles = [ { pos = { x = 0, y = 0 },
                radius = 10,
                vel = { x = 1, y = 1 }
              } ] }                  

genCircles = {

drawWorld : World -> List Form
drawWorld world = [ drawBG ] ++ map drawCircle world.circles

drawBG : Form
drawBG = rect w h |> filled white
                        
drawCircle : Circle -> Form
drawCircle c = circle c.radius |> filled black |> move (c.pos.x, c.pos.y)

update
               
main = collage w h <| drawWorld initWorld
