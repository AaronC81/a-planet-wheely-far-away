class PlayerCar < OZ::Entity
  MAX_HP = 5

  IMAGE = AssetLoader.load_image("player_car.png")

  VERTICAL_CENTRE = (Window::HEIGHT - IMAGE.height) / 2

  VERTICAL_SPEED = 6

  def initialize(**kw)
    super(
      position: OZ::Point.new(50, VERTICAL_CENTRE),
      animations: {
        normal: OZ::Animation.static(IMAGE)
      },
      **kw
    )

    @hp = 5
  end

  attr_reader :hp

  def update
    vertical_velocity = 0
    if Gosu.button_down?(Gosu::KB_W)
      vertical_velocity -= VERTICAL_SPEED
    end
    if Gosu.button_down?(Gosu::KB_S)
      vertical_velocity += VERTICAL_SPEED
    end

    new_y = self.position.y + vertical_velocity
    if new_y < RoadManager::BUILDINGS_START || new_y > Window::HEIGHT - IMAGE.height
      vertical_velocity = 0
    end

    self.position.y += vertical_velocity
    if vertical_velocity > 0
      self.rotation = 2
    elsif vertical_velocity < 0
      self.rotation = -2
    else
      self.rotation = 0
    end
  end

  def hit
    # TODO: death logic
    # TODO: animation or something
    @hp -= 1
  end
end
