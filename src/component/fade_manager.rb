class FadeManager
  TOTAL_TIME = 120
  FADE_TIME = TOTAL_TIME / 2

  def initialize
    @timer = 0
  end

  # Triggers block when halfway so you can swap out the screen
  def fade(&block)
    @timer = TOTAL_TIME
    @callback = block
  end

  def update
    if @timer > 0
      @timer -= 1

      if @timer == FADE_TIME
        @callback.()
      end
    end
  end

  def draw
    return unless @timer > 0

    if @timer < FADE_TIME
      opacity = (@timer.to_f / FADE_TIME) * 255
    elsif @timer > (TOTAL_TIME - FADE_TIME)
      opacity = ((TOTAL_TIME - @timer.to_f) / FADE_TIME) * 255
    else
      opacity = 255
    end
    colour = Gosu::Color.argb(opacity, 0, 0, 0)

    Gosu.draw_rect(0, 0, Window::WIDTH, Window::HEIGHT, colour, 100010)
  end
end
