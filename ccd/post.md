Continous Collision Detection

The motivating problem:
In traditional collision detection we have the problem of fast moving shapes passing through one another without a collision being detected. This is because we sample the world at discrete intervals.

''' haskell
-- discrete collision checking
collisionVector :: Shape -> Shape -> Vec
collisionVector a b = undefined

isColliding :: Shape -> Shape -> Bool
isColliding a b = a `intersects` b

pushApart a b = 

findColliding :: [Shape] -> [(Shape, Shape)]
findColliding shapes = map (\(a, b) -> isColliding a b) pairs
    where pairs = uniqueCross shapes shapes
          checkCollision (a, b) | isColliding a b = handle

uniqueCross : [a] -> [b] -> [(a, b)]
uniqueCross xs ys = concatMap (\x -> (map (\y -> (x, y)) ys)) xs

doCollisionDetection :: [Shape] -> [Shape]
doCollisionDetection shapes = map handleCollision (findColliding shapes)
    where handleCollision (a, b) = 
'''

What we want is a system where collisions will always be detected no matter the speed and size of shapes. That is, instead of sampling the world at discrete intervals, we somehow continously check for collisions.

Since computers can't deal with infinities very well, we'll have to do something else, we can try to find out the time until the collision happens.


''' haskell
-- continous collision checking


