class MothershipEnemy < Enemy
  IMAGE = AssetLoader.load_image("enemies/mothership.png")

  def initialize(**kw)
    super(
      animations: {
        normal: OZ::Animation.static(IMAGE),
      },
      fire_cooldown: 30,
      fire_buffer: 240,
      target_x: 1100,
      hp: 500, # TODO balance, I have no idea
      **kw
    )

    @tilt_while_entering = false

    # This wobbles exactly across stage if Y is BUILDINGS_START
    @wobble_time_divider = 60
    @wobble_amount_divider = 0.26

    @next_attack = :blue

    @is_red_repeating = true
    @red_repeats_this_volley = 0
  end

  RED_REPEAT_COOLDOWN = 6

  def update
    super

    if @next_attack == :red && @fire_cooldown_remaining == RED_REPEAT_COOLDOWN + 12 && !$player.dead?
      AssetLoader.play_sample("sample/laser_charge.wav")
    end
  end

  def fire
    case @next_attack
    when :blue
      AssetLoader.play_sample("sample/laser_pew.wav")
      EnemyBullet.new(
        animations: {
          normal: OZ::Animation.static(AssetLoader.load_image("particles/blue_bullet.png")),
        },
        position: bounding_box.centre,
        velocity: OZ::Point.new(-2, 0),
      ).register(SpawnManager::OBSTACLES_GROUP)

    when :red
      AssetLoader.play_sample("sample/laser_fast_pew.wav")

      EnemyBullet.new(
        animations: {
          normal: OZ::Animation.static(AssetLoader.load_image("particles/red_bullet.png")),
        },
        position: bounding_box.centre,
        velocity: OZ::Point.new(-7, 0),
      ).register(SpawnManager::OBSTACLES_GROUP)

      if @red_repeats_this_volley < 5
        @fire_cooldown = RED_REPEAT_COOLDOWN
        @red_repeats_this_volley += 1

        # Do not reroll attack
        return
      else
        @red_repeats_this_volley = 0
      end

    when :orange
      AssetLoader.play_sample("sample/laser_shotgun.wav")

      10.times do
        angle = rand(220..320)
        velocity = rand(0.5..1.5)
        x_velocity = Gosu.offset_x(angle, velocity)
        y_velocity = Gosu.offset_y(angle, velocity)

        EnemyBullet.new(
          animations: {
            normal: OZ::Animation.static(AssetLoader.load_image("particles/orange_bullet.png")),
          },
          position: bounding_box.centre,
          velocity: OZ::Point.new(x_velocity, y_velocity),
        ).register(SpawnManager::OBSTACLES_GROUP)
      end
    end

    @next_attack = [:blue, :blue, :blue, :red, :red, :orange].sample
    case @next_attack
    when :blue
      @fire_cooldown = 10
    when :red
      @fire_cooldown = 70
    when :orange
      @fire_cooldown = 90
    end
  end
end
