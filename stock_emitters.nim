##
## A set of stock emitters that can be used.
##
## Each emitter can be created by calling the procedure for that emitter with
## an x and y location where that emitter should be drawn.
## 
import csfml, particle, mersenne, times, util, emitter, life

const
  PARTICLE_IMG  = "resources/3.png"
  PARTICLE2_IMG = "resources/2.png"
  PARTICLE3_IMG = "resources/1.png"
  maxParticles  = 2000
let
  greenTexture  = new_texture(PARTICLE_IMG)
  redTexture    = new_texture(PARTICLE2_IMG)
  blueTexture   = new_texture(PARTICLE3_IMG)
  twister       = newMersenneTwister(int(epochTime()))
  prop          = newProperty(2.7, 2.9)
  globePool*    = newParticlePool(greenTexture)
  sunPool*      = newParticlePool(redTexture)
  cometPool*    = newParticlePool(blueTexture)

  # The key to the globe emitter is that the range of 
  # direction the particles can take is very wide (300 degrees)
  # causing a sphere to form.
proc summonGreenGlobe*(x: float, y: float): Emitter =
  ## Summons a green globe to the screen.
  result = newEmitter(
    pool = globePool, 
    x            = x, 
    y            = y, 
    speed        = newProperty(05.00,  0.70), 
    rotation     = newProperty(10.00, 30.00), 
    size         = newProperty(00.25, 00.25), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(4.0, 10.5), 
    maxParticles = maxParticles,
    twister      = twister
  )

# The key to the sun is that there is a large variation in the size of 
# the particles as they are spawned, and then they get smaller as they travel
# farther away from the center point of the emitter.
# This causes the rays to appear to flutter and pulse.
proc summonSun*(x: float, y: float): Emitter =
  ## Summons a red "sun" with pulsing "rays" to the screen.
  result = newEmitter(
    pool         = sunPool, 
    x            = x, 
    y            = y, 
    speed        = newProperty(2.00, 0.50), 
    rotation     = newProperty(3.00, 2.00), 
    size         = newProperty(0.25, 0.25), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(50.0, 2.0), 
    maxParticles = maxParticles,
    twister      = twister
  )

# The key to the explosion animation is that
# the time to live is high but the maximum number of particles
# is low. This means that as the older particles head to the outside
# of the blast radius, the emitter will have run out of particles,
# and the center will hollow out until the entire animation fades out.
proc summonExplosion*(x: float, y: float): Emitter =
  ## Summons a red explosion animation to the screen.
  result = newEmitter(
    pool         = sunPool, 
    x            = x, 
    y            = y, 
    speed        = newProperty(2.00, 0.50), 
    rotation     = newProperty(3.00, 10.00), 
    size         = newProperty(0.125, 2.0), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(80.0, 0.0125), 
    maxParticles = 1000,
    twister      = twister
  ) 
  
# The exhaust emitter works by shooting particles straight down with a medium velocity and a short lifetime.
# Because the lifetime is short, the particles get smaller very quickly, causing a teardrop shape which works
# as an exhaust animation.
proc summonExhaust*(x: float, y: float): Emitter =
  ## Summons an animated afterburner/exhaust flame to the screen.
  result = newEmitter(
    pool         = sunPool, 
    x            = x, 
    y            = y, 
    speed        = newProperty(7.00, 0.50), 
    rotation     = newProperty(1.55, 0.0125), 
    size         = newProperty(0.125, 1.0), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(25.0, 0.0125), 
    maxParticles = 2000,
    twister      = twister
  ) 

proc summonComet*(x: float, y: float): Emitter =
    ## Summons a moving blue comet to the screen.
    result = newEmitter(
      pool         = cometPool, 
      x            = x, 
      y            = y, 
      speed        = newProperty(1.50, 5.1250), 
      rotation     = newProperty(1.50, 0.0125), 
      size         = newProperty(0.25, 0.5000), 
      color        = prop, 
      alpha        = prop, 
      ttl          = newProperty(5.0, 5.0), 
      maxParticles = 1000,
      life         = newLife(true, true, 130),
      twister      = twister
    )

    result.physics.rotation = 04.5
    result.physics.speed    = 10.0
