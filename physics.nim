import csfml, math

type
  Physics* = ref object of RootObj
    location*:  Vector2f
    speed*:     float
    rotation*:  float

proc update*(phys: Physics) =
  phys.location = phys.location + vec2(phys.speed * cos(phys.rotation), phys.speed * sin(phys.rotation))

proc newPhysics*(x: float, y: float): Physics =
  result = new(Physics)

  result.location.x = x
  result.location.y = y