import csfml
import flare

const
  WINDOW_TITLE  = "Flare"
  WINDOW_WIDTH  = 800
  WINDOW_HEIGHT = 600

var window = new_RenderWindow(video_mode(WINDOW_WIDTH, WINDOW_HEIGHT), WINDOW_TITLE)

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
    window.display()
