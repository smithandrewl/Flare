import csfml, flare, mersenne, sequtils, math, times, stock_emitters

discard GC_disable

const
  WINDOW_TITLE     = "Flare Particle FX Demo"
  BACKGROUND_IMG   = "resources/bg.jpg"
  WINDOW_WIDTH     = 1920
  WINDOW_HEIGHT    = 1080
  FONT_SIZE        = 18
  GC_PAUSE         = 200
  MAX_COMETS       = 15
  BACKGROUND_COLOR = color(0, 0, 0, 255)

let
  window     = new_RenderWindow(video_mode(WINDOW_WIDTH, WINDOW_HEIGHT), WINDOW_TITLE)
  bgTexture  = new_texture(BACKGROUND_IMG)
  bgSprite   = new_sprite(bgTexture)

  # Summon the emitters to their places on screen
  greenGlobe = summonGreenGlobe(300, 500)
  sun        = summonSun(900, 500)
  explosion  = summonExplosion(1500, 500)
  exhaust    = summonExhaust(1700, 500)

var comets:        seq[Emitter] = @[]
var activeEmitter: Emitter      = nil

window.vertical_sync_enabled = true

greenGlobe.physics.rotation = 0

var font:         Font = new_Font("resources/DroidSansMono/DroidSansMono.ttf")
var activeLabel:  Text = new_Text("", font)
var pooledLabel:  Text = new_Text("", font)
var usageLabel:   Text = new_Text("Press 'q' to quit, 'f' to launch a comet, 1-2 to control emitters, 3 to detach", font)

usageLabel.position  = vec2(600, 10)
pooledLabel.position = vec2(5,   45)
activeLabel.position = vec2(5,   25)

activeLabel.characterSize = FONT_SIZE
pooledLabel.characterSize = FONT_SIZE
usageLabel.characterSize  = FONT_SIZE

window.mouseCursorVisible = true
while window.open:
    var 
      event: Event
    while window.poll_event(event):
        case event.kind
          of EventType.Closed:
            window.close()
          of EventType.KeyPressed:
            case event.key.code
              of KeyCode.Num1:
                activeEmitter = greenGlobe # The mouse controls the greenGlobe
                mouse_setPosition(vec2(int(activeEmitter.physics.location.x), int(activeEmitter.physics.location.y)))
              of KeyCode.Num2:
                activeEmitter = sun # The mouse controls the sun
                mouse_setPosition(vec2(int(activeEmitter.physics.location.x), int(activeEmitter.physics.location.y)))
              of KeyCode.Num3:
                activeEmitter = nil # The mouse controls nothing
              of KeyCode.F:
                # Summon comets to the screen up to a limit
                if(len(comets) < MAX_COMETS):
                  let comet = summonComet(float(mouse_getPosition().x), float(mouse_getPosition().y))

                  comets.add(comet)

              of KeyCode.Q:
                window.close()
              else: discard
          else:  # Tie the active emitters location to the mouses location
            if activeEmitter != nil:
              activeEmitter.physics.location  = mouse_getPosition()

    window.clear BACKGROUND_COLOR
    window.draw(bgSprite)

    greenGlobe.update
    greenGlobe.draw(window)

    sun.update
    sun.draw(window)
    
    explosion.update
    explosion.draw(window)
    
    exhaust.update
    exhaust.draw(window)
    
    for i, comet in comets:
      if comet.life.IsAlive:
        comet.update
        comet.draw window
      else:
        comet.clear
        comets.delete(i)

    let particleCount   = greenGlobe.len + sun.len     + explosion.len + exhaust.len + sum(mapIt(comets, it.len))
    let pooledParticles = globePool.len  + sunPool.len + cometPool.len
    
    activeLabel.str  = "Active Particles: " & $particleCount
    pooledLabel.str  = "Pooled particles: " & $pooledParticles
    
    window.draw(activeLabel)
    window.draw(pooledLabel)
    window.draw(usageLabel)
    window.display()

    GC_step(GC_PAUSE, true) # After rendering a frame, tell the garbage collector 
                            # it can free memory for a short period of time.
