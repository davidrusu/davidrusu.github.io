-- Things to explain, record update syntax, partial function application, `$` operator, guards, infix functions

import Data.List (delete, tails)
import Data.Maybe (fromJust)

data World = World { shapes :: [Shape] }
data Shape = Shape { pos :: Vec, vel :: Vec } deriving (Eq)
type Vec = (Float, Float)

add (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)

scale s (x, y) = (s * x, s * y)

-- uniquePairs [1, 2, 3, 4] -> [(1, 2), (2, 3), (3, 4), (1, 3), (2, 4), (1, 4)]
uniquePairs :: [a] -> [(a, a)]
uniquePairs xs = foldl (\pairs ys -> pairs ++ (zip xs ys)) [] tails xs

--------------------------------------------------------------------------------
-- Update the world 'dt' milliseconds into the future
update :: Float -> World -> World
update dt world = world { shapes = updateShapes dt (shapes world) }

-- Update shapes 'dt' milliseconds into the future while handling any collisions that come up
updateShapes :: Float -> [Shape] -> [Shape]
updateShapes dt shapes
  | timeToCollision < dt = updateShapes timeLeftInUpdate (handleAnyCollisions shapesAtTimeOfCollision)
  | otherwise            = updatePositions dt shapes
  where
    timeToCollision         = timeToNextCollision shapes
    timeLeftInUpdate        = dt - timeToCollision
    shapesAtTimeOfCollision = updatePositions timeToCollision shapes

-- Updates the position of shapes 'dt' milliseconds into the future
updatePositions :: Float -> [Shape] -> [Shape]
updatePositions dt shapes = map (updatePos dt) shapes
  where updatePos dt shape = shape { pos = (pos shape) `add` (scale dt (vel shape)) }

-- handle all collisions between shapes
handleAnyCollisions :: [Shape] -> [Shape]
handleAnyCollisions shapes = map updateShape shapes
  where updateShape s = s { vel = (vel s) `add` (netImpulse s (delete s shapes)) }

timeToCollision :: (Shape, Shape) -> Maybe Float
timeToCollision (a, b) = undefined -- details...

timeToNextCollision :: [Shape] -> Float
timeToNextCollision shapes = minimum upcomingCollisions
  where upcomingCollisions = map fromJust $ filter (/= Nothing) $ map timeToCollision (uniquePairs shapes)

-- Calculate the net impulse applied, through collisions, to the given shape.
netImpulse :: Shape -> [Shape] -> Vec
netImpulse shape shapes = foldr accumForce (0, 0) shapes
  where accumForce other accum = accum `add` (collisionImpulse shape other)

-- Calculate how much of an impulse we should apply to shape a
collisionImpulse :: Shape -> Shape -> Vec
collisionImpulse a b = case collisionNormal a b of
                       Nothing      -> (0, 0)
                       Just colVec  -> undefined -- more details...

-- If a collision is detected, returns a vector perpendicular to the collision plane, pointing in
-- the shape a direction of the collision plane. Othewise returns Nothing
collisionNormal :: Shape -> Shape -> Maybe Vec
collisionNormal a b = undefined  -- lets not deal with the details just yet

