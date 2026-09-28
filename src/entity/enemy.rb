class Enemy < OZ::Entity
  def initialize(hp:, fire_buffer:, fire_cooldown:, target_x:, fly_in_speed: 10, **kw)
    super(**kw)

    @hp = hp

    @fire_buffer = fire_buffer

    @fire_cooldown = fire_cooldown
    @fire_cooldown_remaining = fire_cooldown

    @target_x = target_x
    @fly_in_speed = fly_in_speed

    @wobble_timer = 0
  end

  def fire
    raise 'abstract'
  end

  def inflict_gun_damage(amount)
    @hp -= amount
    @hp = 0 if @hp < 0

    if @hp <= 0
      VfxManager.add_effect(
        image: AssetLoader.load_image("particles/smoke.png"),
        x: bounding_box.centre.x,
        y: bounding_box.centre.y,
        rotation: rand(0...360),
        duration: 0.3
      )

      AssetLoader.play_sample("sample/poof.wav")
    end
  end

  def dead?
    @hp <= 0
  end

  def update
    if self.position.x > @target_x
      self.rotation = -15
      self.position.x -= @fly_in_speed
    else
      self.rotation = 0
    end

    if @fire_buffer > 0
      @fire_buffer -= 1
    else
      @fire_cooldown_remaining -= 1
    end

    if @fire_cooldown_remaining <= 0
      fire
      @fire_cooldown_remaining = @fire_cooldown
    end

    @wobble_timer += 1
    self.position.y += Math.sin(@wobble_timer.to_f / 20) / 2
  end
end
