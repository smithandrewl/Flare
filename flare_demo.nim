import csfml
import flare
import mersenne
import sequtils
const
  WINDOW_TITLE  = "Flare"
  WINDOW_WIDTH  = 1366
  WINDOW_HEIGHT = 768

var window = new_RenderWindow(video_mode(WINDOW_WIDTH, WINDOW_HEIGHT), WINDOW_TITLE)
var renderState = renderStates(BlendAdd)
var twister =  newMersenneTwister(1)

var particles: seq[Particle] = @[]

proc summonHorde() =
  var fixX = float((twister.getNum mod 400) + 200)
  var fixY = float((twister.getNum mod 200) + 100)
  var rOff = twister.getNum mod 5
  var gOff = twister.getNum mod 5
  var bOff = twister.getNum mod 5


  particles = @[]

  for i in 1..400:
    var
      scale = float((float((twister.getNum mod 25)) * 0.01) + 0.25)
      particle = newParticle("resources/1.png", float(twister.getNum mod 25) + float(twister.getNum mod 100) + fixX, float(twister.getNum mod 25) + float(twister.getNum mod 100) + fixY )
      randXDir: float
      randYDir: float

    randXDir = float(twister.getNum mod 2)
    randYDir = float(twister.getNum mod 2)

    if randXDir != 1:
      randXDir = -1

    if randYDir != 1:
      randYDir = -1

    particle.physics.velocity = vec2(float(twister.getNum mod 800) * float(randXDir) * 0.0025, float(twister.getNum mod 800) * 0.0025)
    particle.sprite.scale = vec2(scale, scale)
    particle.sprite.color = color(255,255,255)
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
      summon_horde()

    window.display()
