class Obstacle < OZ::Entity
  def initialize(image, y)
    super(
      position: OZ::Point.new(Window::WIDTH, y),
      animations: {
        normal: OZ::Animation.static(image),
      },
    )
  end

  def update
    self.position.x -= $speed
  end
end

