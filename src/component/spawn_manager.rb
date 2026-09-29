class SpawnManager < OZ::Component
  OBSTACLES_GROUP = OZ::Group.new

  def initialize
    @timer = 60
  end

  def update
    OBSTACLES_GROUP.update

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
        image = AssetLoader.load_image([true, false].sample ? 'obstacles/wall.png' : 'obstacles/laser_wall.png')
        Obstacle.new(
          image,
          RoadManager.rand_y_for_obstacle(image.height),
        ).register(OBSTACLES_GROUP)

        @timer = 30
      else
        klass = [BlueEnemy, GreenEnemy, RedEnemy].sample
        klass.new(
          position: OZ::Point.new(1900, RoadManager.rand_y_for_obstacle(klass::IMAGE.height)),
        ).register(GunManager::SHOOTABLES_GROUP)

        @timer = 120
      end
    end
  end

  def draw
    OBSTACLES_GROUP.draw
  end
end
