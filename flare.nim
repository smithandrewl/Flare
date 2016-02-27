
##### Physics ############
import csfml

type
  Physics* = ref object of RootObj
    location*:        Vector2f
    velocity*:        Vector2f
    acceleration*:    Vector2f
    angularVelocity*: float
    angularAcc*:      float
    rotation*:        float

proc draw*(phys: Physics)   = discard
proc update*(phys: Physics) = discard
proc newPhysics*(x: float, y: float): Physics =
  var physics = new(Physics)

  physics.location.x = x
  physics.location.y = y

  result = physics

############ Particle ##########################
discard """
    Emitter
    Particle
    ParticlePool

  Emitter (initialized with an object pool)
    physics: Physics

    Velocity:   Property
    Rotation: Property
    Size:    Property
    Color:   Property
    Alpha:   Property

    maxParticles: int
    curParticles: int

    image: texture/image

    methods:
        draw()
        update()
"""

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
    #tint:  Color
    life*: Life
    sprite*: Sprite
    texture*: Texture


proc draw*(particle: Particle, render: RenderWindow) =
  render.draw(particle.sprite, renderStates(BlendAdd))

proc update*(particle: Particle) =
  particle.life.update

  if particle.life.IsAlive:
    particle.physics.update
    particle.sprite.position = particle.physics.location
    particle.sprite.color = color(255,255,255, particle.sprite.color.a - uint8(255 / particle.life.Ttl))

proc newParticle*(textPath: string, x: float; y: float): Particle =
  var
    texture: Texture = new_Texture(textPath)
    particle: Particle = new(Particle)
    sprite: Sprite = new_Sprite(texture)




  let size = texture.size

  sprite.origin = vec2(size.x/2, size.y/2)
  sprite.scale=vec2(0.05, 0.05)
  particle.physics = newPhysics(x, y)
  sprite.position = particle.physics.location
  particle.life = newLife(true, 100)
  particle.sprite = sprite
  result = particle


discard """
ParticlePool
  constructror(number)
  obtain
  release
"""


######### Util ###########

type
  Property*[T] = ref object of RootObj
    startValue: T
    endValue:   T
    variance:   float

proc newProperty*[T](startValue: T, endValue: T, variance: float): Property[T] =
  let property: Property = new(Property)

  property.startValue = startValue
  property.endValue   = endValue
  property.variance   = variance

  result = property

#ObjectPool



