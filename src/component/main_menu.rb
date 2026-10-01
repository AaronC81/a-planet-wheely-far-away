class MainMenu < OZ::Component
  FONT = AssetLoader.load_system_font("Arial", 24)

  def initialize(&block)
    @starting = false
    @start_callback = block
  end

  def draw
    FONT.draw_text("Gosu Game Jam 10", 20, 20, 10000, 1.0, 1.0, Gosu::Color::WHITE)
    FONT.draw_text("Click to start", 20, 70, 10000, 1.0, 1.0, Gosu::Color::WHITE)
  end

  def update
    if !@starting && OZ::Input.click?
      OZ::Input.clear_click

      @starting = true
      $fade.fade do
        @start_callback.()
        @starting = false
      end
    end
  end
end
