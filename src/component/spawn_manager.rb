class SpawnManager < OZ::Component
  OBSTACLES_GROUP = OZ::Group.new

  def initialize
    @timer = 60

    @survival_time = 0
  end

  def update
    @survival_time += 1

    # Speed up over time
    $speed = 6 + ((@survival_time.to_f / 60) / 30)

    OBSTACLES_GROUP.update

    OBSTACLES_GROUP.items.reject! do |obstacle|
      if $player.bounding_box.overlaps?(obstacle.bounding_box)
        if obstacle.is_a?(Pickup)
          obstacle.on_pickup
        else
          $player.hit
        end
        true
      elsif obstacle.position.x + obstacle.image.width < 0
        true
      else
        false
      end
    end

    # TODO: tweak number of spawns over time
    @timer -= 1
    if @timer <= 0
      if [true, false].sample
        image = AssetLoader.load_image(current_obstacle_pool.sample)
        Obstacle.new(
          image,
          RoadManager.rand_y_for_obstacle(image.height),
        ).register(OBSTACLES_GROUP)

        @timer = 30
      else
        klass = current_enemy_pool.sample
        klass.new(
          position: OZ::Point.new(1900, RoadManager.rand_y_for_obstacle(klass::IMAGE.height)),
        ).register(GunManager::SHOOTABLES_GROUP)

        @timer = 120
      end

      # TODO: obviously decrease
      RapidPickup.new.register(OBSTACLES_GROUP)
      HealPickup.new.register(OBSTACLES_GROUP)
    end
  end

  def current_enemy_pool
    if @survival_time < 30*60
      [BlueEnemy]
    elsif @survival_time < 60*60
      [BlueEnemy, GreenEnemy]
    else
      [BlueEnemy, GreenEnemy, RedEnemy]
    end
  end

  def current_obstacle_pool
    if @survival_time < 30*60
      ['obstacles/wall.png']
    else
      ['obstacles/wall.png', 'obstacles/laser_wall.png']
    end
  end

  def draw
    OBSTACLES_GROUP.draw
  end
end
