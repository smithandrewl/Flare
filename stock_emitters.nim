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
  prop          = newProperty(twister, 2.7, 10, 2.9)
  globePool*    = newParticlePool(greenTexture)
  sunPool*      = newParticlePool(redTexture)
  cometPool*    = newParticlePool(blueTexture)

# The key to the globe emitter is that the range of 
# direction the particles can take is very wide (300 degrees)
# causing a sphere to form.
proc summonGreenGlobe*(x: float, y: float): Emitter =
  result = newEmitter(
    pool = globePool, 
    x            = x, 
    y            = y, 
    speed        = newProperty(twister, 05.00, 10, 00.70), 
    rotation     = newProperty(twister, 10.00, 10, 30.00), 
    size         = newProperty(twister, 00.25, 10, 00.25), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(twister, 4.0, 10, 10.5), 
    maxParticles = maxParticles,
    twister      = twister
  )

proc summonSun*(x: float, y: float): Emitter =
  result = newEmitter(
    pool         = sunPool, 
    x            = x, 
    y            = y, 
    speed        = newProperty(twister, 2.00, 10, 0.50), 
    rotation     = newProperty(twister, 3.00, 10, 2.00), 
    size         = newProperty(twister, 0.25, 10, 0.25), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(twister, 50.0, 10, 2.0), 
    maxParticles = maxParticles,
    twister      = twister
  )

# The key to the explosion animation is that
# the time to live is high but the maximum number of particles
# is low. This means that as the older particles head to the outside
# of the blast radius, the emitter will have run out of particles,
# and the center will hollow out until the entire animation fades out.
proc summonExplosion*(x: float, y: float): Emitter =
  result = newEmitter(
    pool         = sunPool, 
    x            = x, 
    y            = y, 
    speed        = newProperty(twister, 2.00, 10, 0.50), 
    rotation     = newProperty(twister, 3.00, 10, 10.00), 
    size         = newProperty(twister, 0.125, 10, 2.0), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(twister, 80.0, 10, 0.0125), 
    maxParticles = 1000,
    twister      = twister
  ) 

proc summonExhaust*(x: float, y: float): Emitter =
  result = newEmitter(
    pool         = sunPool, 
    x            = x, 
    y            = y, 
    speed        = newProperty(twister, 7.00, 10, 0.50), 
    rotation     = newProperty(twister, 1.55, 10, 0.0125), 
    size         = newProperty(twister, 0.125, 10, 1.0), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(twister, 25.0, 10, 0.0125), 
    maxParticles = 2000,
    twister      = twister
  ) 

proc summonComet*(x: float, y: float): Emitter =
    result = newEmitter(
      pool         = cometPool, 
      x            = x, 
      y            = y, 
      speed        = newProperty(twister, 1.50, 10, 5.1250), 
      rotation     = newProperty(twister, 1.50, 10, 0.0125), 
      size         = newProperty(twister, 0.25, 10, 0.5000), 
      color        = prop, 
      alpha        = prop, 
      ttl          = newProperty(twister, 5.0, 10, 5.0), 
      maxParticles = 1000,
      life         = newLife(true, true, 130),
      twister      = twister
    )

    result.physics.rotation = 04.5
    result.physics.speed    = 10.0
