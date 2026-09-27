class TrackManager < OZ::Component
  STRAIGHT_IMAGE = AssetLoader.load_image("straight_track.png")

  VERTICAL_CENTRE = (Window::HEIGHT - STRAIGHT_IMAGE.height) / 2

  # TODO: later we'll need to support curved tracks, junctions, etc
  def initialize
    @offset = 0
  end

  def update
    @offset -= $speed
    @offset = @offset % STRAIGHT_IMAGE.width
  end

  def draw
    x = @offset - STRAIGHT_IMAGE.width
    while x < Window::WIDTH
      STRAIGHT_IMAGE.draw(x, VERTICAL_CENTRE)
      x += STRAIGHT_IMAGE.width
    end
  end
end
