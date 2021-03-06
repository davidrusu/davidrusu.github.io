import Data.List (delete)
type Vec = (Float, Float)

data Shape = Shape { pos :: Vec, vel :: Vec } deriving (Eq)

add :: Vec -> Vec -> Vec
add (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)

scale :: Float -> Vec -> Vec
scale s (x, y) = (s * x, s * y)

-- Returns a vector pointing in the direction shape a should move and with
-- the magnitude being the distance shape a needs to move to stop overlapping
collisionVector :: Shape -> Shape -> Maybe Vec
collisionVector a b = undefined  -- lets deal with the details later

-- Calculate how much we should push shape a from shape b
collisionForce :: Shape -> Shape -> Vec
collisionForce a b = case collisionVector a b of
                       Nothing      -> (0, 0)
                       Just colVec  -> undefined -- more details...

-- Calculate the net force applied (through collisions) to the given shape
-- by all other shapes
netForce :: Shape -> [Shape] -> Vec
netForce shape shapes = foldr updateForce (0, 0) shapes
  where updateForce other a = a `add` (collisionForce shape other)

-- handle all collisions between shapes
collisions :: [Shape] -> [Shape]
collisions shapes = map updateShape shapes
  where updateShape s = s { vel = (vel s) `add` (netForce s (delete s shapes)) }

-- integrate the positions of all the shapes
physics :: Float -> [Shape] -> [Shape]
physics dt shapes = map updateShape shapes
  where updateShape s = s { pos = (pos s) `add` (scale dt (vel s)) }

update :: Float -> [Shape] -> [Shape]
update dt shapes = physics dt $ collisions shapes

