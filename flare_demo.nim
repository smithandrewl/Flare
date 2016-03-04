import csfml, flare, mersenne, sequtils

const
  WINDOW_TITLE     = "Flare"
  WINDOW_WIDTH     = 1366
  WINDOW_HEIGHT    = 768
  PARTICLE_IMG     = "resources/1.png"
  PARTICLE2_IMG    = "resources/2.png"

  BACKGROUND_COLOR = color(0, 0, 0, 255)
  maxParticles     = 40
let
  window           = new_RenderWindow(video_mode(WINDOW_WIDTH, WINDOW_HEIGHT), WINDOW_TITLE)
  texture          = new_texture(PARTICLE_IMG)
  texture2         = new_texture(PARTICLE2_IMG)
  particlePool     = newParticlePool(texture)
  particlePool2     = newParticlePool(texture2)

  prop             = newProperty(2.7, 10, 2.9)
  speed            = newProperty(5, 10, 0.7)
  ttl              = newProperty(4.0, 10, 10.5)
  rotation         = newProperty(10.0, 10, 30.0)

  emitter: Emitter = newEmitter(
    particlePool, 
    0, 
    0, 
    speed = newProperty(5, 10, 0.7), 
    rotation = newProperty(10.0, 10, 30.0), 
    prop, 
    prop, 
    prop, 
    ttl = newProperty(4.0, 10, 10.5), 
    maxParticles
  )
  
  emitter2: Emitter = newEmitter(
    particlePool2, 
    0, 
    0, 
    speed    = newProperty(2.0, 10, 0.5), 
    rotation = newProperty(3.0, 10, 2.0), 
    prop, 
    prop, 
    prop, 
    ttl      = newProperty(25.0, 10, 2.0), 
    maxParticles
  )

window.vertical_sync_enabled = true

emitter.physics.rotation = 0

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
            emitter.physics.location = mouse_getPosition()
            emitter2.physics.location = vec2(mouse_getPosition().x + 500, mouse_getPosition().y)

    window.clear BACKGROUND_COLOR

    emitter.update
    emitter2.update

    emitter.draw(window)
    emitter2.draw(window)

    window.display()
