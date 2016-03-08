import csfml, flare, mersenne, sequtils, math

discard GC_disable

const
  WINDOW_TITLE     = "Flare Demo"
  WINDOW_WIDTH     = 1680
  WINDOW_HEIGHT    = 1050
  PARTICLE_IMG     = "resources/3.png"
  PARTICLE2_IMG    = "resources/2.png"
  PARTICLE3_IMG    = "resources/1.png"

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
  prop             = newProperty(2.7, 10, 2.9)

proc summonGreenGlobe(): Emitter =
  result = newEmitter(
    pool = globePool, 
    x            = 600, 
    y            = 500, 
    speed        = newProperty(5, 10, 0.7), 
    rotation     = newProperty(10.0, 10, 30.0), 
    size         = newProperty(0.25, 10, 0.25), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(4.0, 10, 10.5), 
    maxParticles = maxParticles
  )
  
proc summonSun(): Emitter =
  result = newEmitter(
    pool         = sunPool, 
    x            = 1000, 
    y            = 500, 
    speed        = newProperty(2.0, 10, 0.5), 
    rotation     = newProperty(3.0, 10, 2.0), 
    size         = newProperty(0.25, 10, 0.25), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(50.0, 10, 2.0), 
    maxParticles = maxParticles
  )

proc summonComet(): Emitter =
    result = newEmitter(
      pool         = cometPool, 
      x            = float(mouse_getPosition().x), 
      y            = float(mouse_getPosition().y), 
      speed        = newProperty(1.5, 10, 5.125), 
      rotation     = newProperty(1.5, 10, 0.0125), 
      size         = newProperty(0.25, 10, 0.5), 
      color        = prop, 
      alpha        = prop, 
      ttl          = newProperty(5.0, 10, 5.0), 
      maxParticles = 1000,
      life         = newLife(true, 110)
    )

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
var usageLabel:   Text = new_Text("Press Q to quit, F to launch a comet, 1-2 to control emitters, 3 to detach", font)

usageLabel.position  = vec2(400, 10)
pooledLabel.position = vec2(5, 45)
activeLabel.position = vec2(5, 25)

activeLabel.characterSize = 16
pooledLabel.characterSize = 16
usageLabel.characterSize  = 16

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

                if(len(comets) < 3):
                  let comet = summonComet()
                  
                  comet.physics.rotation = 4.5
                  comet.physics.speed    = 10

                  comets.add(comet)

              of KeyCode.Q:
                window.close()
              else: discard
          else:
            if activeEmitter != nil:
              activeEmitter.physics.location  = mouse_getPosition()
    window.clear BACKGROUND_COLOR

    greenGlobe.update
    sun.update

    for i, comet in comets:
      if comet.life.IsAlive:
        comet.update
      else:
        comets.delete(i)

    greenGlobe.draw(window)
    sun.draw(window)
    
    for comet in comets:
      if comet.life.IsAlive:
        comet.draw window

    let particleCount   = len(greenGlobe.particles) + len(sun.particles) + sum(mapIt(comets, len(it.particles)))
    let pooledParticles = len(greenGlobe.pool.pool) + len(sun.pool.pool) + sum(mapIt(comets, len(it.pool.pool)))
    

    activeLabel.str  = "Active Particles: " & $particleCount
    pooledLabel.str  = "Pooled particles: " & $pooledParticles
    
    window.draw(activeLabel)
    window.draw(pooledLabel)
    window.draw(usageLabel)
    window.display()

    GC_step(200, true)
