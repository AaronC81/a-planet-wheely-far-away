class Portal < OZ::Entity
  IMAGE = AssetLoader.load_image("portal.png")

  def initialize
    super(
      position: OZ::Point.new(2600, RoadManager::BUILDINGS_START),
      animations: {
        normal: OZ::Animation.static(IMAGE),
      },
    )

    @bolt_spawn_timer = 4
  end

  def update
    super

    @bolt_spawn_timer -= 1
    if @bolt_spawn_timer <= 0
      VfxManager.add_effect(
        image: AssetLoader.load_image("portal_bolt_#{rand(1..3)}.png"),
        x: bounding_box.origin.x + rand(-70..0),
        y: bounding_box.origin.y + rand(100..(bounding_box.height-100)),
        x_velocity: -$speed * 60 + 100,
        rotation: rand(-30...30),
        duration: 1
      )
      @bolt_spawn_timer = 3
    end

    self.position.x -= $speed

    if bounding_box.overlaps?($player.bounding_box)
      AssetLoader.play_sample("sample/teleport.wav")
      $road.start_desert_transition
    end
  end
end
