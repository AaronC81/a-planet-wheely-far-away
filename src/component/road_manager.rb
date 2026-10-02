class RoadManager < OZ::Component
  ROAD_IMAGE = AssetLoader.load_image("road.png", retro: true)
  DESERT_ROAD_IMAGE = AssetLoader.load_image("desert_road.png", retro: true)

  # TODO: Many more!
  BG_BUILDINGS = 5.times.map { |i| AssetLoader.load_image("buildings/bg_building_#{i+1}.png") } \
    + 10.times.map { |i| AssetLoader.load_image("buildings/bg_building_spacer.png") }
  FG_BUILDINGS = 7.times.map { |i| AssetLoader.load_image("buildings/fg_building_#{i+1}.png") }

  SPACE_BACKGROUND = AssetLoader.load_image("space_background.png")

  VERTICAL_CENTRE = Window::HEIGHT / 2

  BUILDINGS_START = VERTICAL_CENTRE - 100

  def self.rand_y_for_obstacle(height)
    rand(BUILDINGS_START...(Window::HEIGHT - height))
  end

  # Small overlap between foreground buildings to ensure there are no gaps
  FG_OVERLAP = 3

  def initialize
    @road_offset = 0
    @fg_offset = 0
    @bg_offset = 0

    @fg_sprites = [FG_BUILDINGS.sample]
    @bg_sprites = [BG_BUILDINGS.sample]

    @desert_transition = false
    @desert_transition_timer = 0
    @in_desert = false
  end

  def update
    @road_offset -= $speed
    # 20px of padding is built into the sprite for more seamless overlap
    @road_offset = @road_offset % (ROAD_IMAGE.width - 20)

    @fg_offset -= $speed * 0.25
    if -@fg_offset > (@fg_sprites[0].width - FG_OVERLAP)
      @fg_offset += (@fg_sprites[0].width - FG_OVERLAP)
      @fg_sprites.shift
    end

    @bg_offset -= $speed * 0.15
    if -@bg_offset > @bg_sprites[0].width
      @bg_offset += @bg_sprites[0].width
      @bg_sprites.shift
    end

    if @desert_transition
      @desert_transition_timer -= 1

      if @desert_transition_timer <= 90
        @in_desert = true

        @fg_sprites.clear
        @bg_sprites.clear

        $portal.unregister
      end

      if @desert_transition_timer <= 0
        @desert_transition = false

        $banner.show_banner(AssetLoader.load_image("text/win.png")) do
          $fade.fade do
            MainMenu.enter
          end
        end
      end
    end
  end

  def draw
    # TODO: Small gaps between buildings unexpectedly... maybe make them overlap?

    if @in_desert
      Gosu.draw_rect(0, 0, Window::WIDTH, Window::HEIGHT, Gosu::Color.rgb(100, 175, 200))
    else
      SPACE_BACKGROUND.draw(0, 0)
    end

    # Background
    i = 0
    x = @bg_offset
    while x < Window::WIDTH
      # If we've run out of buildings, generate a new one
      unless @bg_sprites[i]
        @bg_sprites << bg_buildings.sample
      end

      @bg_sprites[i].draw(x, BUILDINGS_START - @bg_sprites[i].height)
      x += @bg_sprites[i].width
      i += 1
    end

    # Foreground
    i = 0
    x = @fg_offset
    while x < Window::WIDTH
      # If we've run out of buildings, generate a new one
      unless @fg_sprites[i]
        @fg_sprites << fg_buildings.sample
      end

      @fg_sprites[i].draw(x, BUILDINGS_START - @fg_sprites[i].height)
      x += @fg_sprites[i].width - FG_OVERLAP
      i += 1
    end

    if @in_desert
      road_image = DESERT_ROAD_IMAGE
    else
      road_image = ROAD_IMAGE
    end
    x = @road_offset - road_image.width
    while x < Window::WIDTH
      road_image.draw(x, BUILDINGS_START - 20)
      x += road_image.width - 20
    end

    if @desert_transition && @desert_transition_timer > 0
      if @desert_transition_timer > 90
        opacity = 255 * ((120 - @desert_transition_timer).to_f / 30)
      else
        opacity = 255 * (@desert_transition_timer.to_f / 90)
      end
      Gosu.draw_rect(0, 0, Window::WIDTH, Window::HEIGHT, Gosu::Color.argb(opacity, 0, 255, 0), 1000000)
    end
  end

  def start_desert_transition
    return if @desert_transition

    @desert_transition = true
    @desert_transition_timer = 120
  end

  def bg_buildings
    if @in_desert
      [AssetLoader.load_image("buildings/bg_desert.png", retro: true)]
    else
      BG_BUILDINGS
    end
  end

  def fg_buildings
    if @in_desert
      [AssetLoader.load_image("buildings/fg_desert.png", retro: true)]
    else
      FG_BUILDINGS
    end
  end
end
