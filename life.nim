type
  Life* = ref object of RootObj
    IsAlive*: bool
    Age*:     int
    Ttl*:     int

proc update*(life: Life) =
  if life.IsAlive:
    if life.Age >= life.Ttl:
      life.IsAlive = false
    else:
      inc(life.Age)

proc newLife*(alive: bool; livesForever: bool = true, ttl: int = 0): Life =
  result = new(Life)

  result.IsAlive = alive
  result.Age     = 0
  result.Ttl     = ttl
