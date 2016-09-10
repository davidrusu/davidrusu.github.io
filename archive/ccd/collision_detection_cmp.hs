data Vec = Vec Float Float deriving (Eq)
data Circle = Circle {pos :: Vec, vel :: Vec, r :: Float} deriving (Eq)
data World = World {circles :: [Circle]}

scale :: Float -> Vec -> Vec
scale s (Vec x y) = Vec x*s y*s

instance Num Vec where
  (Vec x1 y1) + (Vec x2 y2) = Vec (x1+x2) (y1+y2)
  (Vec x1 y1) - (Vec x2 y2) = Vec (x1-x2) (y1-y2)
  abs (Vec x y) = sqrt $ x * x + y * y
  signum v@(Vec 0 0) = v
  signum v = scale (1 / abs v) v -- we define signum on vectors to be the normalized vector
  fromInteger i = Vec (fromInteger i) 0 -- convert to float and set it as x value

-- uniquePairs [1, 2, 3, 4] -> [(1, 2), (2, 3), (3, 4), (1, 3), (2, 4), (1, 4)]
uniquePairs :: [a] -> [(a, a)]
uniquePairs xs = foldl (\pairs ys -> pairs ++ (zip xs ys)) [] tails xs

stepWorld :: World -> World
stepWorld w = w {circles = map (stepCircle world) (circles w)}

intersect :: (Circle, Circle) -> Bool
intersect c1 c2 = abs (pos c2 - pos c1) <= r c1 + r c2

frameTime = 1/60

stepCircle :: World -> Circle -> Circle
stepCircle (World {circles=cs}) c =
  where intersecting = filter uniquePairs cs

physics :: Circle -> Circle
physics circle = circle { p = p circle + (scale frameTime v circle)}
