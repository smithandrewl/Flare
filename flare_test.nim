import unittest
import flare
import csfml

suite "Life tests":
  test "Life: Constructor":
    let life = newLife(false, 20)

    require(life.Age     == 0)
    require(life.IsAlive == false)
    require(life.Ttl     == 20)

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

suite "ParticlePool tests":
  setup:
    let
      texture      = new_texture("resources/1.png") 
      particlePool = newParticlePool(texture)

  test "ParticlePool: Constructor":
    require(particlePool.texture == texture)

  test "ParticlePool: Initializes with 500 particles in the pool":
    require(particlePool.pool.len == 500)
