type
  Life* = ref object of RootObj
    ## Represents an object that ages and dies.

    IsAlive*: bool
    Age*:     int
    Ttl*:     int

proc update*(life: Life) =
  ## Updates the age of `life` by one.
  ## If the object has exceeded its lifetime, it is marked as dead.

  if life.IsAlive:
    if life.Age >= life.Ttl:
      life.IsAlive = false
    else:
      inc(life.Age)

proc newLife*(alive: bool; livesForever: bool = true, ttl: int = 0): Life =
  ## Creates a new Life instance
  
  result = new(Life)

  result.IsAlive = alive
  result.Age     = 0
  result.Ttl     = ttl
