import physics, life, csfml, lists, mersenne, util

type

  Particle* = ref object of RootObj
    ## Represents a single particle with physics and a lifetime.

    physics*: Physics
    life*:    Life
    sprite*:  Sprite
    texture*: Texture

proc draw*(particle: Particle, render: RenderWindow) =
  ## Draws the particle to the screen.

  render.draw(particle.sprite, renderStates(BlendAdd))


proc update*(particle: Particle) =
  ## Updates the current state of the particle.

  # Update the life component (increments the age and marks as dead)
  particle.life.update

  # If the particle is alive:
  #   * update the physics and move the image to the updated location
  #   * Update the opacity/alpha of the image based on how old the particle is
  #   * Update the size of the image based on the age of the particle 
  if particle.life.IsAlive:      
    particle.physics.update     
    particle.sprite.position = particle.physics.location

    let alpha = uint8(float(particle.sprite.color.a) - (255 / particle.life.Ttl))

    particle.sprite.color = color(particle.sprite.color.r,  particle.sprite.color.g, particle.sprite.color.b, alpha)
    
    let size = max(0, particle.sprite.scale.x - (0.25 / float(particle.life.Ttl)))

    particle.sprite.scale = vec2(size, size)


proc newParticle*(texture: Texture, x: float; y: float): Particle =
  ## Creates a new Particle instance

  let
    sprite: Sprite = new_Sprite(texture)
    size           = texture.size

  result = new(Particle)

  sprite.origin   = vec2(size.x / 2, size.x / 2)
  sprite.scale    = vec2(0.125, 0.125)
  result.physics  = newPhysics(x, y)
  sprite.position = result.physics.location
  result.life     = newLife(true, false, 255)
  result.sprite   = sprite

type
  ParticlePool* = ref object of RootObj
    ## Holds unused or dead particles to keep them in memory,
    ## preventing the garbage collector from running every time a particle dies.

    pool*:    seq[Particle]
    count:    int
    freeList: DoublyLinkedList[Particle] # This list contains the items in "pool" that are unused

    texture*: Texture

proc grow(particlePool: ParticlePool, by: int) =
    ## Increases the number of particles in the pool by allocating and storing new particle instances.

    for i in 1..by:
      let particle: Particle = newParticle(particlePool.texture, 0, 0)

      particle.life.Ttl     = 255
      particle.life.Age     = 0
      particle.life.IsAlive = true

      particlePool.pool.add(particle)
      particlePool.freeList.prepend(particle)
      inc(particlePool.count)
      

proc borrow*(pool: ParticlePool, x: float, y: float, color: Color, ttl: int, speed: float, rotation: float, size: float): Particle =
  ## Takes a particle out of `pool` and returns it with the specified values.
  
  if pool.count == 0: pool.grow(10)

  dec(pool.count)
  result = pool.freeList.head.value
  pool.freeList.remove(pool.freeList.head)

  result.physics.location = vec2(x, y)
  result.physics.rotation = rotation
  result.physics.speed    = speed
  result.life.Age         = 0
  result.life.Ttl         = ttl
  result.life.IsAlive     = true
  result.sprite.color     = color
  result.sprite.scale     = vec2(size, size)

proc ret*(pool: ParticlePool, particle: Particle) =
  ## Returns a particle to `pool`.

  pool.freeList.prepend(particle)
  inc(pool.count)

proc len*(pool: ParticlePool): int =
  ## The number of unused particles in `pool`.
  pool.count

proc newParticlePool*(texture: Texture): ParticlePool =
  ## Creates a new ParticlePool instance
  
  result = new(ParticlePool)

  result.pool     = @[]
  result.freeList = initDoublyLinkedList[Particle]()
  result.texture  = texture
  result.count    = 0
  result.grow(100)
