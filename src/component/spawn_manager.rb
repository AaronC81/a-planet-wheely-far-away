class SpawnManager < OZ::Component
  OBSTACLES_GROUP = OZ::Group.new

  def initialize
    @obstacle_timer = 60
    @enemy_timer = 900 # Bit of delay before enemy spawns

    @pickup_timer = rand((60*90)..(60*120))

    @survival_time = 0
  end

  def update
    @survival_time += 1

    # Speed up over time
    $speed = 6 + ((@survival_time.to_f / 60) / 30)
    $speed_mph = 3 + ($speed * 4.5).round

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

    @obstacle_timer -= 1
    if @obstacle_timer <= 0
      image = AssetLoader.load_image(current_obstacle_pool.sample)
      Obstacle.new(
        image,
        RoadManager.rand_y_for_obstacle(image.height),
      ).register(OBSTACLES_GROUP)

      # Only changes a little bit - speed makes this inherently harder
      if @survival_time > 120*60
        @obstacle_timer = rand(40..70)
      else
        @obstacle_timer = rand(50..80)
      end
    end
    
    @enemy_timer -= 1
    if @enemy_timer <= 0
      klass = current_enemy_pool.sample
      klass.new(
        position: OZ::Point.new(1900, RoadManager.rand_y_for_obstacle(klass::IMAGE.height)),
      ).register(GunManager::SHOOTABLES_GROUP)

      if @survival_time > 220*60
        @enemy_timer = rand(90..160)
      elsif @survival_time > 140*60
        @enemy_timer = rand(100..180)
      else
        @enemy_timer = rand(120..200)
      end
    end

    # TODO: balance depending on how long a run takes
    @pickup_timer -= 1
    if @pickup_timer <= 0
      klass = [RapidPickup, HealPickup].sample
      klass.new.register(OBSTACLES_GROUP)

      @pickup_timer = rand((60*60)..(60*90))
    end
  end

  def current_enemy_pool
    if @survival_time < 60*60
      [BlueEnemy]
    elsif @survival_time < 120*60
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
