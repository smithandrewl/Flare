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
var
  particles: seq[Particle] = @[]
  twister: MersenneTwister = newMersenneTwister(1)

proc summonHorde() =
  let
    fixX = float((twister.getNum mod MAX_FIX_X) + MIN_FIX_X)
    fixY = float((twister.getNum mod MAX_FIX_Y) + MIN_FIX_Y)

  particles = @[]

  for i in 1..NUM_PARTICLES:
    let
      scale = float((float((twister.getNum mod MAX_SCALE)) * SCALE_FACTOR) + MIN_SCALE)
      x = float(float(twister.getNum mod MAX_PART_SPAWN_VAR) + fixX)
      y = float(float(twister.getNum mod MAX_PART_SPAWN_VAR) + fixY)

      particle = particlePool.borrow(x, y, SPAWN_COLOR, FULL_OPACITY)

    var
      randXDir = float(twister.getNum mod 2)
      randYDir = float(twister.getNum mod 2)

    if randXDir != 1:
      randXDir = -1

    if randYDir != 1:
      randYDir = -1

    particle.physics.velocity = vec2(
      float(twister.getNum mod MAX_VEL) * float(randXDir) * VEL_SCALE_FACTOR, 
      float(twister.getNum mod MAX_VEL) * VEL_SCALE_FACTOR
    )

    particle.sprite.scale = vec2(scale, scale)
    particle.sprite.color = SPAWN_COLOR

    particles.add(particle)

window.vertical_sync_enabled = true

while window.open:
    var event: Event
    while window.poll_event(event):
        case event.kind
          of EventType.Closed:
            window.close()
          of EventType.KeyPressed:
            case event.key.code
              of KeyCode.Q:
                window.close()
              else: discard
          else: discard

    window.clear BACKGROUND_COLOR

    for particle in particles:
      particle.update

      if particle.life.IsAlive:
        particle.draw(window)

    if particles.allIt(not it.life.IsAlive):
      for particle in particles:
        particlePool.ret(particle)

      summon_horde()

    window.display()
