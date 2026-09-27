class RoadManager < OZ::Component
  # TODO: this can also be responsible for parallax backgrounds etc
  # (Ideally the road should look "elevated" so buildings can just go directly behind)
  # Maybe we have a large always-occupied front layer - so there's always something - with occasional notable back buildings

  STRAIGHT_IMAGE = AssetLoader.load_image("straight_track.png")

  VERTICAL_CENTRE = (Window::HEIGHT - STRAIGHT_IMAGE.height) / 2

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
