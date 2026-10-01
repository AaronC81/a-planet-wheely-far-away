class MainMenu < OZ::Component
  FONT = AssetLoader.load_font("font/Ranchers-Regular.ttf", 24)
  BUTTON_FONT = AssetLoader.load_font("font/Ranchers-Regular.ttf", 56)

  LOGO = AssetLoader.load_image("text/logo.png")

  PLAY_BUTTON = OZ::Box.new(OZ::Point.new((Window::WIDTH - 400) / 2, 600), 400, 80)

  def initialize(&block)
    @starting = false
    @start_callback = block
  end

  def draw
    Gosu.draw_rect(0, 0, Window::WIDTH, Window::HEIGHT, Gosu::Color.argb(255, 21, 21, 21))

    LOGO.draw((Window::WIDTH - LOGO.width) / 2, 50)

    colour = PLAY_BUTTON.point_inside?(OZ::Input.cursor) ? Gosu::Color.argb(255, 40, 40, 40) : Gosu::Color::BLACK
    Gosu.draw_rect(PLAY_BUTTON.origin.x, PLAY_BUTTON.origin.y, PLAY_BUTTON.width, PLAY_BUTTON.height, colour)
    BUTTON_FONT.draw_text_rel("Play!", PLAY_BUTTON.origin.x + PLAY_BUTTON.width / 2, PLAY_BUTTON.origin.y + PLAY_BUTTON.height / 2, 10000, 0.5, 0.5, 1.0, 1.0, Gosu::Color::WHITE)

    # TODO: name and credits once font is chosen
    # FONT.draw_text_rel("Created by Aaron Christiansen\nfor Gosu Game Jam 10", 20, Window::HEIGHT - 20, 10000, 0, 0, 1.0, 1.0, Gosu::Color::WHITE)
    # FONT.draw_text("Click to start", 20, 70, 10000, 1.0, 1.0, Gosu::Color::WHITE)
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
    end
  end
end
