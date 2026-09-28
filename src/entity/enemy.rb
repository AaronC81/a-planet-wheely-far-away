class Enemy < OZ::Entity
  def initialize(fire_cooldown:, **kw)
    super(**kw)

    @hp = 20

    @fire_buffer = 120

    @fire_cooldown = fire_cooldown
    @fire_cooldown_remaining = fire_cooldown
  end

  def fire
    EnemyBullet.new(
      position: bounding_box.centre,
      velocity: OZ::Point.new(-2, 0),
    ).register(SpawnManager::OBSTACLES_GROUP)
  end

  def inflict_gun_damage(amount)
    @hp -= amount
    @hp = 0 if @hp < 0

    if @hp <= 0
      unregister
      # TODO: explosion animation
    end
  end

  def update
    if @fire_buffer > 0
      @fire_buffer -= 1
    else
      @fire_cooldown_remaining -= 1
    end

    if @fire_cooldown_remaining <= 0
      fire
      @fire_cooldown_remaining = @fire_cooldown
    end
  end
end
