import csfml, flare, mersenne, sequtils, math, times

discard GC_disable

const
  WINDOW_TITLE     = "Flare Demo"
  WINDOW_WIDTH     = 1920
  WINDOW_HEIGHT    = 1080
  PARTICLE_IMG     = "resources/3.png"
  PARTICLE2_IMG    = "resources/2.png"
  PARTICLE3_IMG    = "resources/1.png"
  FONT_SIZE        = 16
  MAX_COMETS       = 15
  GC_PAUSE         = 200
  BACKGROUND_COLOR = color(0, 0, 0, 255)
  maxParticles     = 2000
let
  window           = new_RenderWindow(video_mode(WINDOW_WIDTH, WINDOW_HEIGHT), WINDOW_TITLE)
  texture          = new_texture(PARTICLE_IMG)
  texture2         = new_texture(PARTICLE2_IMG)
  texture3         = new_texture(PARTICLE3_IMG)
  globePool        = newParticlePool(texture)
  sunPool          = newParticlePool(texture2)
  cometPool        = newParticlePool(texture3)
  twister          = newMersenneTwister(int(epochTime()))
  prop             = newProperty(twister, 2.7, 10, 2.9)


proc summonGreenGlobe(): Emitter =
  result = newEmitter(
    pool = globePool, 
    x            = 600, 
    y            = 500, 
    speed        = newProperty(twister, 05.00, 10, 00.70), 
    rotation     = newProperty(twister, 10.00, 10, 30.00), 
    size         = newProperty(twister, 00.25, 10, 00.25), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(twister, 4.0, 10, 10.5), 
    maxParticles = maxParticles,
    twister      = twister
  )
  
proc summonSun(): Emitter =
  result = newEmitter(
    pool         = sunPool, 
    x            = 1200, 
    y            = 500, 
    speed        = newProperty(twister, 2.00, 10, 0.50), 
    rotation     = newProperty(twister, 3.00, 10, 2.00), 
    size         = newProperty(twister, 0.25, 10, 0.25), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(twister, 50.0, 10, 2.0), 
    maxParticles = maxParticles,
    twister      = twister
  )

proc summonComet(): Emitter =
    result = newEmitter(
      pool         = cometPool, 
      x            = float(mouse_getPosition().x), 
      y            = float(mouse_getPosition().y), 
      speed        = newProperty(twister, 1.50, 10, 5.1250), 
      rotation     = newProperty(twister, 1.50, 10, 0.0125), 
      size         = newProperty(twister, 0.25, 10, 0.5000), 
      color        = prop, 
      alpha        = prop, 
      ttl          = newProperty(twister, 5.0, 10, 5.0), 
      maxParticles = 1000,
      life         = newLife(true, 130),
      twister      = twister
    )

    result.physics.rotation = 04.5
    result.physics.speed    = 10.0

let
  greenGlobe = summonGreenGlobe()
  sun        = summonSun()

var comets:        seq[Emitter] = @[]
var activeEmitter: Emitter      = nil

window.vertical_sync_enabled = true

greenGlobe.physics.rotation = 0

var font:         Font = new_Font("resources/DroidSansMono/DroidSansMono.ttf")
var activeLabel:  Text = new_Text("", font)
var pooledLabel:  Text = new_Text("", font)
var usageLabel:   Text = new_Text("Press 'q' to quit, 'f' to launch a comet, 1-2 to control emitters, 3 to detach", font)

usageLabel.position  = vec2(600, 10)
pooledLabel.position = vec2(5,   45)
activeLabel.position = vec2(5,   25)

activeLabel.characterSize = FONT_SIZE
pooledLabel.characterSize = FONT_SIZE
usageLabel.characterSize  = FONT_SIZE

while window.open:
    var 
      event: Event
    while window.poll_event(event):
        case event.kind
          of EventType.Closed:
            window.close()
          of EventType.KeyPressed:
            case event.key.code
              of KeyCode.Num1:
                activeEmitter = greenGlobe
                mouse_setPosition(vec2(int(activeEmitter.physics.location.x), int(activeEmitter.physics.location.y)))
              of KeyCode.Num2:
                activeEmitter = sun
                mouse_setPosition(vec2(int(activeEmitter.physics.location.x), int(activeEmitter.physics.location.y)))
              of KeyCode.Num3:
                activeEmitter = nil
              of KeyCode.F:

                if(len(comets) < MAX_COMETS):
                  let comet = summonComet()

                  comets.add(comet)

              of KeyCode.Q:
                window.close()
              else: discard
          else:
            if activeEmitter != nil:
              activeEmitter.physics.location  = mouse_getPosition()
    window.clear BACKGROUND_COLOR

    greenGlobe.update
    greenGlobe.draw(window)

    sun.update

    sun.draw(window)
    
    for i, comet in comets:
      if comet.life.IsAlive:
        comet.update
        comet.draw window
      else:
        comet.clear
        comets.delete(i)

    let particleCount   = greenGlobe.len + sun.len     + sum(mapIt(comets, it.len))
    let pooledParticles = globePool.len  + sunPool.len + cometPool.len
    
    activeLabel.str  = "Active Particles: " & $particleCount
    pooledLabel.str  = "Pooled particles: " & $pooledParticles
    
    window.draw(activeLabel)
    window.draw(pooledLabel)
    window.draw(usageLabel)
    window.display()

    GC_step(GC_PAUSE, true)
