import csfml
import mersenne
import math

######### Util ###########

type
  Property* = ref object of RootObj
    startValue: float
    endValue:   float
    variance:   float

proc newProperty*(startValue: float, endValue: float, variance: float): Property =
  let property: Property = new(Property)

  property.startValue = startValue
  property.endValue   = endValue
  property.variance   = variance

  result = property

##### Physics ############

type
  Physics* = ref object of RootObj
    location*:        Vector2f
    speed*:           float
    rotation*:        float

proc update*(phys: Physics) =
  phys.location = phys.location + vec2(phys.speed * cos(phys.location.x), phys.speed * sin(phys.location.y))

proc newPhysics*(x: float, y: float): Physics =
  var physics = new(Physics)

  physics.location.x = x
  physics.location.y = y

  result = physics

############ Particle ##########################
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
      life.Age = life.Age + 1

proc newLife*(alive: bool; ttl: int): Life =
  let life: Life = new(Life)

  life.IsAlive = alive
  life.Age     = 0
  life.Ttl     = ttl

  result = life

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
    particle.sprite.color = color(particle.sprite.color.r,  particle.sprite.color.g, particle.sprite.color.b, uint8(float(particle.sprite.color.a) - (100/ particle.life.Ttl)))

proc newParticle*(texture: Texture, x: float; y: float): Particle =
  let
    particle: Particle = new(Particle)
    sprite:   Sprite   =   new_Sprite(texture)
    size               = texture.size

  sprite.origin    = vec2(size.x/2, size.x/2)
  sprite.scale     = vec2(0.125, 0.125)
  particle.physics = newPhysics(x, y)
  sprite.position  = particle.physics.location
  particle.life    = newLife(true, 255)
  particle.sprite  = sprite
  result           = particle

type
  ParticlePool* = ref object of RootObj
    pool*:    seq[Particle]
    texture*: Texture

proc grow(particlePool: ParticlePool, by: int) =
    for i in 1..by:
      let
        particle: Particle = newParticle(particlePool.texture, 0, 0)

      particle.life.Ttl     = 255
      particle.life.Age     = 0
      particle.life.IsAlive = true

      particlePool.pool.add(particle)

proc borrow*(pool: ParticlePool, x: float, y: float, color: Color, ttl: int, speed: float, rotation: float): Particle =
  if len(pool.pool) == 0:
    pool.grow(1000)

  result = pool.pool.pop

  result.physics.location = vec2(x, y)
  result.physics.rotation = rotation
  result.physics.speed = speed
  result.life.Age     = 0
  result.life.Ttl     = ttl
  result.life.IsAlive = true

  result.sprite.color = color
  result.sprite.scale = vec2(0.125, 0.125)

proc ret*(pool: ParticlePool, particle: Particle) =
  pool.pool.add(particle)

proc newParticlePool*(texture: Texture): ParticlePool =
  result = new(ParticlePool)

  result.pool    = @[]
  result.texture = texture

  result.grow(1000)

type
  Emitter* = ref object of RootObj
    pool: ParticlePool
    physics*: Physics
    twister: MersenneTwister

    speed*: Property
    rotation*:  Property
    size*:      Property
    color*:     Property
    alpha*:     Property

    maxParticles*: int
    curParticles: int
    particles: seq[Particle]
    texture*: Texture

proc randProperty(twister: var MersenneTwister, property: Property): (float, float) =
  var
    startVar    = property.startValue * property.variance
    endVar      = property.endValue   * property.variance
    startValue  = property.startValue + float(twister.getNum mod int(startVar))
    endValue    = property.endValue   + float(twister.getNum mod int(endVar))

  result = (startValue, endValue)

proc draw*(emitter: Emitter, render: RenderWindow) =
  for particle in emitter.particles:
    particle.draw render

proc update*(emitter: Emitter) =
  for i, particle in emitter.particles:
    particle.update

    if particle.life.IsAlive != true:
      emitter.pool.ret(particle)
      emitter.particles.delete(i)
  
  

  if emitter.curParticles < emitter.maxParticles:
    for i in 1..min(50, emitter.maxParticles - emitter.curParticles):
      var
        xVel: float = randProperty(emitter.twister, emitter.speed)[0]
      emitter.particles.add(emitter.pool.borrow(emitter.physics.location.x, emitter.physics.location.y, color(255,255,255,255),  50, xVel, 0))




proc newEmitter*(
  pool:      ParticlePool,
  x:         float,
  y:         float,
  speed:     Property,
  rotation:  Property,
  size:      Property,
  color:     Property,
  alpha:     Property,
  maxParticles: int): Emitter =

  result = new(Emitter)

  result.twister = newMersenneTwister(1)


  result.physics = newPhysics(x, y)

  result.maxParticles = maxParticles
  result.curParticles = 0
  result.particles    = @[]

  result.pool         = pool
  result.speed        = speed
  result.rotation     = rotation
  result.size         = size
  result.color        = color
  result.alpha        = alpha
  
