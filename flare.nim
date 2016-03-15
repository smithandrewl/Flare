import csfml, mersenne, math, sequtils, lists

type
  Property* = ref object of RootObj
    twister:    MersenneTwister
    startValue: float
    endValue:   float
    variance:   float

proc newProperty*(twister: MersenneTwister, startValue: float, endValue: float, variance: float): Property =
  result = new(Property)

  result.twister    = twister
  result.startValue = startValue
  result.endValue   = endValue
  result.variance   = variance

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

proc newLife*(alive: bool; ttl: int): Life =
  result = new(Life)

  result.IsAlive = alive
  result.Age     = 0
  result.Ttl     = ttl

type
  Particle* = ref object of RootObj
    physics*: Physics
    life*:    Life
    sprite*:  Sprite
    texture*: Texture

proc draw*(particle: Particle, render: RenderWindow) =
  render.draw(particle.sprite, renderStates(BlendAdd))

proc update*(particle: Particle) =
  particle.life.update

  if particle.life.IsAlive:
    particle.physics.update
    particle.sprite.position = particle.physics.location

    let alpha = uint8(float(particle.sprite.color.a) - (255 / particle.life.Ttl))

    particle.sprite.color = color(particle.sprite.color.r,  particle.sprite.color.g, particle.sprite.color.b, alpha)
    
    let size = max(0, particle.sprite.scale.x - (0.25 / float(particle.life.Ttl)))

    particle.sprite.scale = vec2(size, size)


proc newParticle*(texture: Texture, x: float; y: float): Particle =
  let
    sprite: Sprite = new_Sprite(texture)
    size           = texture.size

  result = new(Particle)

  sprite.origin   = vec2(size.x / 2, size.x / 2)
  sprite.scale    = vec2(0.125, 0.125)
  result.physics  = newPhysics(x, y)
  sprite.position = result.physics.location
  result.life     = newLife(true, 255)
  result.sprite   = sprite

type
  ParticlePool* = ref object of RootObj
    pool*:    seq[Particle]
    count:    int
    freeList: DoublyLinkedList[Particle]

    texture*: Texture

proc grow(particlePool: ParticlePool, by: int) =
    for i in 1..by:
      let particle: Particle = newParticle(particlePool.texture, 0, 0)

      particle.life.Ttl     = 255
      particle.life.Age     = 0
      particle.life.IsAlive = true

      particlePool.pool.add(particle)
      particlePool.freeList.prepend(particle)
      inc(particlePool.count)
      
proc borrow*(pool: ParticlePool, x: float, y: float, color: Color, ttl: int, speed: float, rotation: float, size: float): Particle =
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
  pool.freeList.prepend(particle)
  inc(pool.count)

proc len*(pool: ParticlePool): int =
  pool.count

proc newParticlePool*(texture: Texture): ParticlePool =
  result = new(ParticlePool)

  result.pool    = @[]
  result.freeList = initDoublyLinkedList[Particle]()
  result.texture = texture
  result.count = 0
  result.grow(100)

type
  Emitter* = ref object of RootObj
    pool*:         ParticlePool
    physics*:      Physics
    twister:       MersenneTwister
    speed*:        Property
    rotation*:     Property
    size*:         Property
    color*:        Property
    alpha*:        Property
    ttl*:          Property
    maxParticles*: int  
    curParticles:  int
    particles*:    seq[Particle]
    texture*:      Texture
    life*:         Life

proc get*(property: Property): (float, float) =
  let
    startVar:   float   = property.startValue * property.variance
    endVar:     float   = property.endValue   * property.variance
    sign:       float   = if (property.twister.getNum mod 2) == 1: 1 else: -1
    startValue: float   = property.startValue + (sign * (float((property.twister.getNum * 1000) mod int(startVar * 1000)) / 1000))
    endValue:   float   = property.endValue   + (sign * (float((property.twister.getNum * 1000) mod int(endVar   * 1000)) / 100))

  result = (startValue, endValue)

proc draw*(emitter: Emitter, render: RenderWindow) =
  for particle in emitter.particles:
    particle.draw render

proc update*(emitter: Emitter) =
  
  if emitter.life != nil:
    emitter.life.update

  emitter.physics.update

  for i, particle in emitter.particles:
    particle.update

    if particle.life.IsAlive != true:
      emitter.pool.ret(particle)
      emitter.particles.delete(i)
      dec(emitter.curParticles)

  if emitter.curParticles < emitter.maxParticles:
    for i in 1..min(50, emitter.maxParticles - emitter.curParticles):
      let
        speed:    float    = emitter.speed.get[0]
        ttl:      int      = int(emitter.ttl.get[0])
        rotation: float    = emitter.rotation.get[0]
        size:     float    = emitter.size.get[0]
        
        particle: Particle = emitter.pool.borrow(
          emitter.physics.location.x, 
          emitter.physics.location.y, 
          color(255,255,255,0),  
          ttl, 
          speed, 
          rotation, size
        )
      
      if particle != nil:
        emitter.particles.add(particle)
        inc(emitter.curParticles)

proc clear*(emitter: Emitter) =
  for i, particle in emitter.particles:
    emitter.pool.ret(particle)
    emitter.particles.delete(i)
    dec(emitter.curParticles)

proc len*(emitter: Emitter): int =
  emitter.particles.len

proc newEmitter*(
  pool:         ParticlePool,  
  x:            float,
  y:            float,
  speed:        Property,
  rotation:     Property,
  size:         Property,
  color:        Property,
  alpha:        Property,
  ttl:          Property,
  maxParticles: int,
  life:         Life = nil,
  twister: MersenneTwister
): Emitter =

  result = new(Emitter)

  result.twister      = twister
  result.physics      = newPhysics(x, y)
  result.maxParticles = maxParticles
  result.curParticles = 0
  result.particles    = @[]
  result.pool         = pool
  result.speed        = speed
  result.rotation     = rotation
  result.size         = size
  result.color        = color
  result.alpha        = alpha
  result.ttl          = ttl
  result.life         = life
