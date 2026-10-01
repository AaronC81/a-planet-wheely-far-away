class BannerManager
  TOTAL_BANNER_TIME = 240
  FADE_TIME = 30

  def show_banner(image, &block)
    @current_banner = image
    @banner_timer = TOTAL_BANNER_TIME
    @callback = block
  end

  def update
    if @current_banner
      @banner_timer -= 1

      if @banner_timer <= 0
        @current_banner = nil
        @callback.() if @callback
      end
    end
  end

  def draw
    return unless @current_banner

    if @banner_timer < FADE_TIME
      opacity = (@banner_timer.to_f / FADE_TIME) * 255
    elsif @banner_timer > (TOTAL_BANNER_TIME - FADE_TIME)
      opacity = ((TOTAL_BANNER_TIME - @banner_timer.to_f) / FADE_TIME) * 255
    else
      opacity = 255
    end
    colour = Gosu::Color.argb(opacity, 255, 255, 255)

    @current_banner.draw((Window::WIDTH - @current_banner.width) / 2, 200, 100010, 1.0, 1.0, colour)
  end
end
