import csfml, flare, mersenne, sequtils

const
  WINDOW_TITLE     = "Flare"
  WINDOW_WIDTH     = 1366
  WINDOW_HEIGHT    = 768
  PARTICLE_IMG     = "resources/1.png"
  BACKGROUND_COLOR = color(0, 0, 0, 255)

let
  window           = new_RenderWindow(video_mode(WINDOW_WIDTH, WINDOW_HEIGHT), WINDOW_TITLE)
  texture          = new_texture(PARTICLE_IMG)
  particlePool     = newParticlePool(texture)
  prop             = newProperty(2.7, 10, 2.9)
  speed            = newProperty(10.0, 10, 0.7)
  ttl              = newProperty(10.0, 10, 10.5)
  emitter: Emitter = newEmitter(particlePool, 400.0, 400.0, speed, prop, prop, prop, prop, ttl, 400)

window.vertical_sync_enabled = true

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

    window.clear BACKGROUND_COLOR

    emitter.update
    emitter.draw(window)

    window.display()
