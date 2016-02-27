import csfml
import flare
import mersenne

const
  WINDOW_TITLE  = "Flare"
  WINDOW_WIDTH  = 800
  WINDOW_HEIGHT = 600

var window = new_RenderWindow(video_mode(WINDOW_WIDTH, WINDOW_HEIGHT), WINDOW_TITLE)
var renderState = renderStates(BlendAdd)
var twister =  newMersenneTwister(1)

var particles: seq[Particle] = @[]

for i in 1..250:
  var particle = newParticle("resources/1.png", float(twister.getNum mod 50) + 100, float(twister.getNum mod 50) + 100 )
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
      else:
        particle.life.IsAlive = true
        particle.life.Age = 0


    window.display()
