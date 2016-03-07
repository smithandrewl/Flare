import csfml, flare, mersenne, sequtils

const
  WINDOW_TITLE     = "Flare Demo"
  WINDOW_WIDTH     = 1366
  WINDOW_HEIGHT    = 768
  PARTICLE_IMG     = "resources/1.png"
  PARTICLE2_IMG    = "resources/2.png"

  BACKGROUND_COLOR = color(0, 0, 0, 255)
  maxParticles     = 2000
let
  window           = new_RenderWindow(video_mode(WINDOW_WIDTH, WINDOW_HEIGHT), WINDOW_TITLE)
  texture          = new_texture(PARTICLE_IMG)
  texture2         = new_texture(PARTICLE2_IMG)
  particlePool     = newParticlePool(texture)
  particlePool2    = newParticlePool(texture2)
  prop             = newProperty(2.7, 10, 2.9)

  emitter: Emitter = newEmitter(
    pool = particlePool, 
    x            = 0, 
    y            = 0, 
    speed        = newProperty(5, 10, 0.7), 
    rotation     = newProperty(10.0, 10, 30.0), 
    size         = newProperty(0.25, 10, 0.5), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(4.0, 10, 10.5), 
    maxParticles = maxParticles
  )
  
  emitter2: Emitter = newEmitter(
    pool = particlePool2, 
    x            = 0, 
    y            = 0, 
    speed        = newProperty(2.0, 10, 0.5), 
    rotation     = newProperty(3.0, 10, 2.0), 
    size         = newProperty(0.25, 10, 0.5), 
    color        = prop, 
    alpha        = prop, 
    ttl          = newProperty(50.0, 10, 2.0), 
    maxParticles = maxParticles
  )

window.vertical_sync_enabled = true

emitter.physics.rotation = 0

var font:  Font = new_Font("resources/DroidSansMono/DroidSansMono.ttf")
var text:  Text = new_Text("", font)
var text2: Text = new_Text("", font)
var text3: Text = new_Text("Press Q to quit", font)

text3.position = vec2(600, 10)
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
              of KeyCode.Q:
                window.close()
              else: discard
          else:
            emitter.physics.location  = mouse_getPosition()
            emitter2.physics.location = vec2(mouse_getPosition().x + 500, mouse_getPosition().y)

    window.clear BACKGROUND_COLOR

    emitter.update
    emitter2.update

    emitter.draw(window)
    emitter2.draw(window)

    let particleCount   = len(emitter.particles) + len(emitter2.particles)
    let pooledParticles = len(emitter.pool.pool) + len(emitter2.pool.pool)
    
    text.str  = "Active Particles: " & $particleCount
    text2.str = "Pooled particles: " & $pooledParticles
    
    window.draw(text)
    window.draw(text2)
    window.draw(text3)
    window.display()
