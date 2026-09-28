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
        BlueEnemy.new(
          position: OZ::Point.new(1900, RoadManager.rand_y_for_obstacle(BlueEnemy::IMAGE.height)),
        ).register(GunManager::SHOOTABLES_GROUP)

        @timer = 120
      end
    end
  end
end
