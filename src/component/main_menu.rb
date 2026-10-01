class MainMenu < OZ::Component
  FONT = AssetLoader.load_font("font/Ranchers-Regular.ttf", 24)
  TUTORIAL_FONT = AssetLoader.load_font("font/Ranchers-Regular.ttf", 36)
  BUTTON_FONT = AssetLoader.load_font("font/Ranchers-Regular.ttf", 56)
  SMALL_BUTTON_FONT = AssetLoader.load_font("font/Ranchers-Regular.ttf", 48)

  LOGO = AssetLoader.load_image("text/logo.png")

  PLAY_BUTTON = OZ::Box.new(OZ::Point.new((Window::WIDTH - 400) / 2, 550), 400, 80)
  ASSIST_BUTTON = OZ::Box.new(OZ::Point.new((Window::WIDTH - 300) / 2, 700), 300, 70)

  def initialize(&block)
    @starting = false
    @start_callback = block
  end

  def draw
    Gosu.draw_rect(0, 0, Window::WIDTH, Window::HEIGHT, Gosu::Color.argb(255, 21, 21, 21))

    LOGO.draw(50, 50)

    colour = PLAY_BUTTON.point_inside?(OZ::Input.cursor) ? Gosu::Color.argb(255, 40, 40, 40) : Gosu::Color::BLACK
    Gosu.draw_rect(PLAY_BUTTON.origin.x, PLAY_BUTTON.origin.y, PLAY_BUTTON.width, PLAY_BUTTON.height, colour)
    BUTTON_FONT.draw_text_rel("Play!", PLAY_BUTTON.origin.x + PLAY_BUTTON.width / 2, PLAY_BUTTON.origin.y + PLAY_BUTTON.height / 2, 10000, 0.5, 0.5, 1.0, 1.0, Gosu::Color::WHITE)

    colour = ASSIST_BUTTON.point_inside?(OZ::Input.cursor) ? Gosu::Color.argb(255, 40, 40, 40) : Gosu::Color::BLACK
    Gosu.draw_rect(ASSIST_BUTTON.origin.x, ASSIST_BUTTON.origin.y, ASSIST_BUTTON.width, ASSIST_BUTTON.height, colour)
    SMALL_BUTTON_FONT.draw_text_rel($assist_mode ? "[ON] Assist Mode" : "Assist Mode", ASSIST_BUTTON.origin.x + ASSIST_BUTTON.width / 2, ASSIST_BUTTON.origin.y + ASSIST_BUTTON.height / 2, 10000, 0.5, 0.5, 1.0, 1.0, Gosu::Color::WHITE)

    if ASSIST_BUTTON.point_inside?(OZ::Input.cursor)
      FONT.draw_text("This game is intended to be challenging and tense.\nHowever, if it's too difficult but you'd still like to experience\nthe entire game, enable Assist Mode to prevent Game Overs.", ASSIST_BUTTON.origin.x + ASSIST_BUTTON.width + 20, ASSIST_BUTTON.origin.y, 10000, 1.0, 1.0, Gosu::Color::WHITE)
    end

    # TODO: name and credits once font is chosen
    FONT.draw_text("Created by Aaron Christiansen\nfor Gosu Game Jam 10\n\nSounds from Freesound: TODO", 20, Window::HEIGHT - 120, 10000, 1.0, 1.0, Gosu::Color::WHITE)

    draw_tutorial(700, 80)
  end

  def draw_tutorial(x, y)
    TUTORIAL_FONT.draw_text("Reach 100mph to get home!\nDodge obstacles and defeat enemies.", x, y, 10000, 1.0, 1.0, Gosu::Color::WHITE)

    TUTORIAL_FONT.draw_text("[W] Move up\n[S] Move down\n[Left-click] Fire gun\n[R] Reload gun", x, y + 100, 10000, 1.0, 1.0, Gosu::Color::WHITE)

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
    end
  end
end
