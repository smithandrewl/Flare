import csfml, math

type
  Physics* = ref object of RootObj
    ## Implements very simple 2d physics using a location, speed and orientation (rotation).
    ## Each time `update` is called, the `location` field will be adjusted.

    location*:  Vector2f
    speed*:     float
    rotation*:  float

proc update*(phys: Physics) =
  ## updates the location

  phys.location = phys.location + vec2(phys.speed * cos(phys.rotation), phys.speed * sin(phys.rotation))

proc newPhysics*(x: float, y: float): Physics =
  ## Returns a new Physics instance
  
  result = new(Physics)

  result.location.x = x
  result.location.y = y