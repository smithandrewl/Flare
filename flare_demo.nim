import csfml
import flare
import mersenne
import sequtils

const
  WINDOW_TITLE  = "Flare"
  WINDOW_WIDTH  = 1366
  WINDOW_HEIGHT = 768

var
  particles: seq[Particle] = @[]
  twister: MersenneTwister = newMersenneTwister(1)

let
  window       = new_RenderWindow(video_mode(WINDOW_WIDTH, WINDOW_HEIGHT), WINDOW_TITLE)
  texture      = new_texture("resources/1.png")
  particlePool = newParticlePool(texture)

proc summonHorde() =
  let
    fixX = float((twister.getNum mod 400) + 200)
    fixY = float((twister.getNum mod 200) + 100)

  particles = @[]

  for i in 1..800:
    let
      scale = float((float((twister.getNum mod 25)) * 0.01) + 0.25)
      x = float(twister.getNum mod 25) + float(twister.getNum mod 100) + fixX
      y = float(twister.getNum mod 25) + float(twister.getNum mod 100) + fixY

      particle = particlePool.borrow(x, y, color(255,255,255, 255), 255)

    var
      randXDir = float(twister.getNum mod 2)
      randYDir = float(twister.getNum mod 2)

    if randXDir != 1:
      randXDir = -1

    if randYDir != 1:
      randYDir = -1

    particle.physics.velocity = vec2(float(twister.getNum mod 800) * float(randXDir) * 0.0025, float(twister.getNum mod 800) * 0.0025)
    particle.sprite.scale     = vec2(scale, scale)
    particle.sprite.color     = color(255,255,255)

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
              else:
                discard " "
          else: discard

    window.clear color(0, 0, 0)

    for particle in particles:
      particle.update


      if particle.life.IsAlive:
        particle.draw(window)

    if particles.allIt(it.life.IsAlive != true):
      for particle in particles:
        particlePool.ret(particle)

      summon_horde()

    window.display()
