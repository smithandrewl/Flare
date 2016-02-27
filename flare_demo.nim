import csfml
import flare

const
  WINDOW_TITLE  = "Flare"
  WINDOW_WIDTH  = 800
  WINDOW_HEIGHT = 600

var window = new_RenderWindow(video_mode(WINDOW_WIDTH, WINDOW_HEIGHT), WINDOW_TITLE)
var particle = newParticle(50.0, 50.0)

let particle_texture = new_Texture("resources/1.png")
let particle_sprite = new_Sprite(particle_texture)
let size = particle_texture.size

particle_sprite.origin = vec2(size.x/2, size.y/2)
particle_sprite.scale=vec2(0.05, 0.05)
particle_sprite.position = vec2(particle.physics.location.x, particle.physics.location.y)

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

    particle.update


    if particle.life.IsAlive:
      echo particle.life.Age
      particle_sprite.color= color(255, 255, 255, particle_sprite.color.a - uint8((255 / particle.life.Ttl)))
      window.draw particle_sprite
    else:
      particle.life.IsAlive = true
      particle.life.Age = 0
      particle_sprite.position = vec2(particle.physics.location.x, particle.physics.location.y)
      particle_sprite.color = color(0,0,0,255)


    window.display()
