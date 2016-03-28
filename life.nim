
# Represents an object that ages and dies.
type
  Life* = ref object of RootObj
    IsAlive*: bool
    Age*:     int
    Ttl*:     int

# Each call to update ages the object by one.
# If the object has exceeded its lifetime, it is marked as dead
proc update*(life: Life) =
  if life.IsAlive:
    if life.Age >= life.Ttl:
      life.IsAlive = false
    else:
      inc(life.Age)

# Creates a new Life instance
proc newLife*(alive: bool; livesForever: bool = true, ttl: int = 0): Life =
  result = new(Life)

  result.IsAlive = alive
  result.Age     = 0
  result.Ttl     = ttl
