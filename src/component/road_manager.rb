class RoadManager < OZ::Component
  STRAIGHT_IMAGE = AssetLoader.load_image("straight_track.png")

  # TODO: Many more!
  BG_BUILDINGS = 2.times.map { |i| AssetLoader.load_image("buildings/bg_building_#{i+1}.png") } \
    + 4.times.map { |i| AssetLoader.load_image("buildings/bg_building_spacer.png") }
  FG_BUILDINGS = 4.times.map { |i| AssetLoader.load_image("buildings/fg_building_#{i+1}.png") }

  VERTICAL_CENTRE = (Window::HEIGHT - STRAIGHT_IMAGE.height) / 2

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
  end

  def update
    @road_offset -= $speed
    @road_offset = @road_offset % STRAIGHT_IMAGE.width

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
  end

  def draw
    # TODO: Small gaps between buildings unexpectedly... maybe make them overlap?

    # Background
    i = 0
    x = @bg_offset
    while x < Window::WIDTH
      # If we've run out of buildings, generate a new one
      unless @bg_sprites[i]
        @bg_sprites << BG_BUILDINGS.sample
      end

      @bg_sprites[i].draw(x, BUILDINGS_START - @bg_sprites[i].height, 999)
      x += @bg_sprites[i].width
      i += 1
    end

    # Foreground
    i = 0
    x = @fg_offset
    while x < Window::WIDTH
      # If we've run out of buildings, generate a new one
      unless @fg_sprites[i]
        @fg_sprites << FG_BUILDINGS.sample
      end

      @fg_sprites[i].draw(x, BUILDINGS_START - @fg_sprites[i].height, 1000)
      x += @fg_sprites[i].width - FG_OVERLAP
      i += 1
    end

    x = @road_offset - STRAIGHT_IMAGE.width
    while x < Window::WIDTH
      STRAIGHT_IMAGE.draw(x, VERTICAL_CENTRE)
      x += STRAIGHT_IMAGE.width
    end
  end
end
