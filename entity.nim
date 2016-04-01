import life, physics, csfml, util

type
  Entity* = ref object of RootObj
    life:    Life
    physics: Physics
    radius:  float

proc isColliding*(left: Entity, right: Entity): bool = 
  ## Returns true if `left` and `right` are colliding.

  let
    leftLoc    = left.physics.location
    rightLoc   = right.physics.location
    minDist    = left.radius + right.radius
    actualDist = distance(leftLoc.x, leftLoc.y, rightLoc.x, rightLoc.y)

  result = actualDist < minDist

proc newEntity*(x: float, y: float, alive: bool): Entity =
  result         = new(Entity)
  result.life    = newLife(alive = true)
  result.physics = newPhysics(x, y)

proc `radius=`*(entity: Entity, radius: float) =
  entity.radius = radius

proc `location=`*(entity: Entity, location: Vector2f) = 
  entity.physics.location = location

proc `IsAlive=`*(entity: Entity, status: bool) =
  entity.life.IsAlive = status

proc `speed=`*(entity: Entity, speed: float) =
  entity.physics.speed = speed

proc `rotation=`*(entity: Entity, rotation: float) =
  entity.physics.rotation = rotation

proc radius*(entity: Entity): float = 
  entity.radius

proc location*(entity: Entity): Vector2f =
  entity.physics.location

proc IsAlive*(entity: Entity): bool =
  entity.life.IsAlive

proc speed*(entity: Entity): float =
  entity.physics.speed

proc rotation*(entity: Entity): float =
  entity.physics.rotation

proc update*(entity: Entity) =
  entity.life.update
  entity.physics.update