import csfml, math

# Implements very simple 2d physics using a location, speed and orientation (rotation).
# Each time update is called, the location field will be adjusted.

type
  Physics* = ref object of RootObj
    location*:  Vector2f
    speed*:     float
    rotation*:  float

# updates the location using basic trigonometry
proc update*(phys: Physics) =
  phys.location = phys.location + vec2(phys.speed * cos(phys.rotation), phys.speed * sin(phys.rotation))

# Returns a new Physics instance
proc newPhysics*(x: float, y: float): Physics =
  result = new(Physics)

  result.location.x = x
  result.location.y = y