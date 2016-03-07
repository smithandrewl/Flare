import csfml, flare, mersenne, sequtils, math

discard GC_disable

const
  WINDOW_TITLE     = "Flare Demo"
  WINDOW_WIDTH     = 1366
  WINDOW_HEIGHT    = 768
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
  particlePool     = newParticlePool(texture)
  particlePool2    = newParticlePool(texture2)
  particlePool3    = newParticlePool(texture3)
  prop             = newProperty(2.7, 10, 2.9)

  emitter: Emitter = newEmitter(
    pool = particlePool, 
    x            = 400, 
    y            = 400, 
    speed        = newProperty(5, 10, 0.7), 
    rotation     = newProperty(10.0, 10, 30.0), 
    size         = newProperty(0.25, 10, 0.25), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(4.0, 10, 10.5), 
    maxParticles = maxParticles
  )
  
  emitter2: Emitter = newEmitter(
    pool = particlePool2, 
    x            = 800, 
    y            = 400, 
    speed        = newProperty(2.0, 10, 0.5), 
    rotation     = newProperty(3.0, 10, 2.0), 
    size         = newProperty(0.25, 10, 0.25), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(50.0, 10, 2.0), 
    maxParticles = maxParticles
  )

var comets: seq[Emitter] = @[]

var activeEmitter: Emitter = nil

window.vertical_sync_enabled = true

emitter.physics.rotation = 0

var font:  Font = new_Font("resources/DroidSansMono/DroidSansMono.ttf")
var text:  Text = new_Text("", font)
var text2: Text = new_Text("", font)
var text3: Text = new_Text("Press Q to quit, F to launch a comet, 1-2 to control emitters, 3 to detach", font)

text3.position = vec2(400, 10)
text2.position = vec2(5, 45)
text.position  = vec2(5, 25)

text.characterSize  = 16
text2.characterSize = 16
text3.characterSize = 16

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
                activeEmitter = emitter
                mouse_setPosition(vec2(int(activeEmitter.physics.location.x), int(activeEmitter.physics.location.y)))
              of KeyCode.Num2:
                activeEmitter = emitter2
                mouse_setPosition(vec2(int(activeEmitter.physics.location.x), int(activeEmitter.physics.location.y)))
              of KeyCode.Num3:
                activeEmitter = nil
              of KeyCode.F:

                if(len(comets) < 5):

                  var comet = newEmitter(
                        pool = particlePool3, 
                        x            = float(mouse_getPosition().x), 
                        y            = float(mouse_getPosition().y), 
                        speed        = newProperty(1.5, 10, 5.125), 
                        rotation     = newProperty(1.5, 10, 0.0125), 
                        size         = newProperty(0.125, 10, 0.5), 
                        color        = prop, 
                        alpha        = prop, 
                        ttl          = newProperty(5.0, 10, 5.0), 
                        maxParticles = 600,
                        life = newLife(true, 90)
                  )
                  
                  comet.physics.rotation = 4.5
                  comet.physics.speed = 10

                  comets.add(comet)

              of KeyCode.Q:
                window.close()
              else: discard
          else:
            if activeEmitter != nil:
              activeEmitter.physics.location  = mouse_getPosition()
    window.clear BACKGROUND_COLOR

    emitter.update
    emitter2.update

    for i, comet in comets:
      if comet.life.IsAlive:
        comet.update
      else:
        comets.delete(i)

    emitter.draw(window)
    emitter2.draw(window)
    
    for comet in comets:
      if comet.life.IsAlive:
        comet.draw window

    let particleCount   = len(emitter.particles) + len(emitter2.particles) + sum(mapIt(comets, len(it.particles)))
    let pooledParticles = len(emitter.pool.pool) + len(emitter2.pool.pool) + sum(mapIt(comets, len(it.pool.pool)))
    

    text.str  = "Active Particles: " & $particleCount
    text2.str = "Pooled particles: " & $pooledParticles
    
    window.draw(text)
    window.draw(text2)
    window.draw(text3)
    window.display()

    GC_step(200, true)
