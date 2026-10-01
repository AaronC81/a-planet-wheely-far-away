class Portal < OZ::Entity
  IMAGE = AssetLoader.load_image("portal.png")

  def initialize
    super(
      position: OZ::Point.new(1900, RoadManager::BUILDINGS_START),
      animations: {
        normal: OZ::Animation.static(IMAGE),
      },
    )
  end

  def update
    super

    self.position.x -= $speed

    if bounding_box.overlaps?($player.bounding_box)
      $road.start_desert_transition
    end
  end
end
