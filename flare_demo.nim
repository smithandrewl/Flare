import csfml
import flare
import mersenne
import sequtils

const
  WINDOW_TITLE  = "Flare"
  WINDOW_WIDTH  = 1366
  WINDOW_HEIGHT = 768
  MAX_FIX_X = 400
  MAX_FIX_Y = 200
  MIN_FIX_X = 200
  MIN_FIX_Y = 100

  SCALE_FACTOR = 0.01
  MAX_SCALE = 25
  MIN_SCALE = 0.25

  MAX_PART_SPAWN_VAR = 125
  MAX_VEL = 800
  VEL_SCALE_FACTOR = 0.0025
  FULL_OPACITY = 255
  NUM_PARTICLES = 800

  PARTICLE_IMG = "resources/1.png"

let
  window           = new_RenderWindow(video_mode(WINDOW_WIDTH, WINDOW_HEIGHT), WINDOW_TITLE)
  texture          = new_texture(PARTICLE_IMG)
  particlePool     = newParticlePool(texture)
  SPAWN_COLOR      = color(255, 255, 255, 255)
  BACKGROUND_COLOR = color(0, 0, 0, 255)
  prop = newProperty(2.7, 10, 2.9)
  yVel = newProperty(9, 10, 0.9)
  emitter: Emitter = newEmitter(particlePool, 400, 400, prop, prop, prop, prop, prop, yVel, 50)
var
  particles: seq[Particle] = @[]
  twister: MersenneTwister = newMersenneTwister(1)

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
