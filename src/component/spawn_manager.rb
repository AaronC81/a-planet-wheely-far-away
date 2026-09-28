class SpawnManager < OZ::Component
  OBSTACLES_GROUP = OZ::Group.new

  def initialize
    @timer = 60

    OBSTACLES_GROUP.register
  end

  def update
    OBSTACLES_GROUP.items.reject! do |obstacle|
      if $player.bounding_box.overlaps?(obstacle.bounding_box)
        $player.hit
        true
      elsif obstacle.position.x + obstacle.image.width < 0
        true
      else
        false
      end
    end

    # TODO: make this way less awful obviously
    @timer -= 1
    if @timer <= 0
      if [true, false].sample
        image = AssetLoader.load_image('obstacles/wall.png')
        Obstacle.new(
          image,
          RoadManager.rand_y_for_obstacle(image.height),
        ).register(OBSTACLES_GROUP)

        @timer = 30
      else
        image = AssetLoader.load_image("enemies/blue_ufo.png")
        Enemy.new(
          position: OZ::Point.new(1900, RoadManager.rand_y_for_obstacle(image.height)),
          animations: {
            normal: OZ::Animation.static(image),
          },
          fire_cooldown: rand(40...90),
          target_x: rand(900..1400),
        ).register(GunManager::SHOOTABLES_GROUP)

        @timer = 120
      end
    end
  end
end
