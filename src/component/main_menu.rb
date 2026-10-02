class MainMenu < OZ::Component
  FONT = AssetLoader.load_font("font/Ranchers-Regular.ttf", 24)
  TUTORIAL_FONT = AssetLoader.load_font("font/Ranchers-Regular.ttf", 36)
  BUTTON_FONT = AssetLoader.load_font("font/Ranchers-Regular.ttf", 56)
  SMALL_BUTTON_FONT = AssetLoader.load_font("font/Ranchers-Regular.ttf", 48)
  CREDIT_FONT = AssetLoader.load_font("font/Ranchers-Regular.ttf", 18)

  LOGO = AssetLoader.load_image("text/logo.png")

  PLAY_BUTTON = OZ::Box.new(OZ::Point.new((Window::WIDTH - 400) / 2, 500), 400, 80)
  ASSIST_BUTTON = OZ::Box.new(OZ::Point.new((Window::WIDTH - 300) / 2, 600), 300, 70)
  FULLSCREEN_BUTTON = OZ::Box.new(OZ::Point.new((Window::WIDTH - 300) / 2, 690), 300, 70)
  MUSIC_BUTTON = OZ::Box.new(OZ::Point.new((Window::WIDTH - 300) / 2, 780), 300, 70)

  SAMPLE_CREDITS = %w[
xXKRONOSXx
eardeer
Sophia_C
mikiko850
AceOfSpadesProduc100
Sustainededed
saangosu
unfa
SamsterBirdies
moodyfingers
eardeer
morganpurkis
EminYILDIRIM
peepholecircus
Kronos1001
Sergenious
bennychico11
VSE00
swifty433
.Andre_Onate
jppi_Stu
phenoxy
TomaszBuga
Nox_Sound
Yudena
BrickDeveloper171
StonedB
solarpsychedelic
]

  def initialize(&block)
    @starting = false
    @start_callback = block
  end

  def self.enter
    AssetLoader.play_song("song/menu.wav")
    $state = :main_menu
  end

  def draw
    Gosu.draw_rect(0, 0, Window::WIDTH, Window::HEIGHT, Gosu::Color.argb(255, 21, 21, 21))

    LOGO.draw(150, 50, 0)

    draw_button(PLAY_BUTTON, "Play!", BUTTON_FONT)
    draw_button(ASSIST_BUTTON, $assist_mode ? "[ON] Assist Mode" : "[OFF] Assist Mode", SMALL_BUTTON_FONT)
    draw_button(FULLSCREEN_BUTTON, $fullscreen ? "[ON] Fullscreen" : "[OFF] Fullscreen", SMALL_BUTTON_FONT)
    draw_button(MUSIC_BUTTON, $music ? "[ON] Music" : "[OFF] Music", SMALL_BUTTON_FONT)

    if ASSIST_BUTTON.point_inside?(OZ::Input.cursor)
      FONT.draw_text("This game is intended to be\nchallenging and tense.\nIf it's too difficult but you'd still\nlike to experience the entire\ngame, enable Assist Mode to\nprevent Game Overs.", ASSIST_BUTTON.origin.x + ASSIST_BUTTON.width + 20, ASSIST_BUTTON.origin.y, 10000, 1.0, 1.0, Gosu::Color::WHITE)
    end

    # TODO: name and credits once font is chosen
    FONT.draw_text("Created by Aaron Christiansen\nfor Gosu Game Jam 10", 20, Window::HEIGHT - 80, 10000, 1.0, 1.0, Gosu::Color::WHITE)

    FONT.draw_text_rel("Sounds from Freesound:", Window::WIDTH - 20, Window::HEIGHT - 350, 10000, 1, 0.5, 1.0, 1.0, Gosu::Color::WHITE)
    (SAMPLE_CREDITS.length/3).times do |i|
      credits = SAMPLE_CREDITS[(i*3)..(i*3+2)]
      CREDIT_FONT.draw_text_rel(credits.join(", "), Window::WIDTH - 20, Window::HEIGHT - 350 + 20 * (i + 1), 10000, 1, 0.5, 1.0, 1.0, Gosu::Color::WHITE)
    end

    FONT.draw_text_rel("Music:", Window::WIDTH - 20, Window::HEIGHT - 120, 10000, 1, 0.5, 1.0, 1.0, Gosu::Color::WHITE)
    CREDIT_FONT.draw_text_rel("Menu: 'UNKNOWN_ENTITY' by GloryToTheMachine (Freesound)", Window::WIDTH - 20, Window::HEIGHT - 120 + 20, 10000, 1, 0.5, 1.0, 1.0, Gosu::Color::WHITE)
    CREDIT_FONT.draw_text_rel("Game: 'Eighties Action' by Kevin MacLeod", Window::WIDTH - 20, Window::HEIGHT - 120 + 40, 10000, 1, 0.5, 1.0, 1.0, Gosu::Color::WHITE)

    FONT.draw_text_rel("Icons from Icons8", Window::WIDTH - 20, Window::HEIGHT - 40, 10000, 1, 0.5, 1.0, 1.0, Gosu::Color::WHITE)

    draw_tutorial(950, 80)
  end

  def draw_button(box, text, font)
    colour = box.point_inside?(OZ::Input.cursor) ? Gosu::Color.argb(255, 40, 40, 40) : Gosu::Color::BLACK
    Gosu.draw_rect(box.origin.x, box.origin.y, box.width, box.height, colour)
    font.draw_text_rel(text, box.origin.x + box.width / 2, box.origin.y + box.height / 2, 10000, 0.5, 0.5, 1.0, 1.0, Gosu::Color::WHITE)
  end

  def draw_tutorial(x, y)
    TUTORIAL_FONT.draw_text("Reach 100mph to get back home!\nDodge obstacles and defeat enemies.", x, y, 10000, 1.0, 1.0, Gosu::Color::WHITE)

    TUTORIAL_FONT.draw_text("[W] Move up\n[S] Move down\n[Left-click] Fire gun (aim with cursor)\n[R] Reload gun", x, y + 100, 10000, 1.0, 1.0, Gosu::Color::WHITE)

    TUTORIAL_FONT.draw_text("Collect pickups:", x, y + 280, 10000, 1.0, 1.0, Gosu::Color::WHITE)
    AssetLoader.load_image("pickup/heal_pickup.png").draw(x + 190, y + 270, 10000, 0.8, 0.8)
    AssetLoader.load_image("pickup/rapid_pickup.png").draw(x + 260, y + 270, 10000, 0.8, 0.8)
  end

  def update
    if !@starting && OZ::Input.click?
      OZ::Input.clear_click

      if PLAY_BUTTON.point_inside?(OZ::Input.cursor)
        @starting = true
        $fade.fade do
          @start_callback.()
          @starting = false
        end
      end

      if ASSIST_BUTTON.point_inside?(OZ::Input.cursor)
        $assist_mode = !$assist_mode
      end

      if FULLSCREEN_BUTTON.point_inside?(OZ::Input.cursor)
        $window.toggle_fullscreen
      end

      if MUSIC_BUTTON.point_inside?(OZ::Input.cursor)
        $music = !$music

        if Gosu::Song.current_song
          Gosu::Song.current_song.stop
        end

        AssetLoader.play_song("song/menu.wav")
      end
    end
  end
end
