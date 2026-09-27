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

    if self.position.x + image.width < 0
      unregister
    end
  end

  def check_collision
    if $player.bounding_box.overlaps?(bounding_box)
      puts "COLLIDE!" # TODO
      unregister
    end
  end
end

