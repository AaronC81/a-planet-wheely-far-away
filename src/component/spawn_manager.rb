class SpawnManager < OZ::Component
  OBSTACLES_GROUP = OZ::Group.new

  def initialize
    @obstacle_timer = 60
    @enemy_timer = 450 # Bit of delay before enemy spawns

    @pickup_timer = 60*60

    @survival_time = 0

    @has_spawned_mothership = false
  end

  attr_accessor :obstacle_timer

  def update
    @survival_time += 1

    # Speed up over time
    $speed_mph = 2 + ($speed * 5.5).round
    unless $speed_mph >= 100
      $speed = 6 + ((@survival_time.to_f / 60) / 30)
    end

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

      if $speed_mph > 75
        @obstacle_timer = rand(30..60)
      elsif $speed_mph > 55
        @obstacle_timer = rand(40..70)
      else
        @obstacle_timer = rand(50..80)
      end
    end
    
    if $speed_mph >= 100 && !@has_spawned_mothership
      @has_spawned_mothership = true

      $mothership = MothershipEnemy.new(
        position: OZ::Point.new(1900, RoadManager::BUILDINGS_START),
      )
      $mothership.register(GunManager::SHOOTABLES_GROUP)
    end

    @enemy_timer -= 1
    if @enemy_timer <= 0 && !@has_spawned_mothership
      klass = current_enemy_pool.sample
      klass.new(
        position: OZ::Point.new(1900, RoadManager.rand_y_for_obstacle(klass::IMAGE.height)),
      ).register(GunManager::SHOOTABLES_GROUP)

      if $speed_mph > 50
        @enemy_timer = rand(90..180)
      else
        @enemy_timer = rand(100..200)
      end

      # Combo spawn!
      if rand > 0.8
        @enemy_timer = rand(5..15)
      end
    end

    @pickup_timer -= 1
    if @pickup_timer <= 0
      if $assist_mode
        klass = RapidPickup
      else
        klass = [RapidPickup, HealPickup].sample
      end
      klass.new.register(OBSTACLES_GROUP)

      @pickup_timer = rand((60*55)..(60*75))
    end
  end

  def current_enemy_pool
    if $speed_mph < 40
      [BlueEnemy]
    elsif $speed_mph < 45
      [BlueEnemy, GreenEnemy]
    elsif $speed_mph < 50
      [BlueEnemy, GreenEnemy, RedEnemy]
    elsif $speed_mph < 60
      [BlueEnemy, GreenEnemy, RedEnemy, PinkEnemy]
    else
      [BlueEnemy, GreenEnemy, RedEnemy, PinkEnemy, OrangeEnemy]
    end
  end

  def current_obstacle_pool
    if $speed_mph < 45
      ['obstacles/wall.png']
    else
      ['obstacles/wall.png', 'obstacles/laser_wall.png']
    end
  end

  def draw
    OBSTACLES_GROUP.draw
  end
end
