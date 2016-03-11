import unittest
import flare

suite "Life tests":
  test "Life: Constructor sets values":
    let life = newLife(false, 20)

    require(life.Age == 0)
    require(life.IsAlive == false)
    require(life.Ttl == 20)

  test "Life: Age updates by one each step":
    let life: Life = newLife(true, 110)
    
    life.update

    require(life.Age == 1)
  
  test "Life: Still alive after a step":
    let life: Life = newLife(true, 1)

    life.update

    require(life.IsAlive == true)

  test "Life: Death when age is greater than time to live":
    let life = newLife(true, 1)

    life.update
    life.update

    require(life.IsAlive == false)

    life.update
  
  