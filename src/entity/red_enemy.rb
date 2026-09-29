class RedEnemy < Enemy
  IMAGE = AssetLoader.load_image("enemies/red_ufo.png")

  def initialize(**kw)
    super(
      animations: {
        normal: OZ::Animation.static(IMAGE),
      },
      fire_cooldown: rand(30...50),
      fire_buffer: rand(100...150),
      target_x: rand(900..1400),
      hp: 15,
      **kw
    )

    @is_repeating = true
    @repeats_this_volley = 0
  end

  REPEAT_COOLDOWN = 8

  def update
    super

    if @fire_cooldown_remaining == REPEAT_COOLDOWN + 12 && !$player.dead?
      AssetLoader.play_sample("sample/laser_charge.wav")
    end
  end

  def fire
    AssetLoader.play_sample("sample/laser_fast_pew.wav")

    EnemyBullet.new(
      animations: {
        normal: OZ::Animation.static(AssetLoader.load_image("particles/red_bullet.png")),
      },
      position: bounding_box.centre,
      velocity: OZ::Point.new(-7, 0),
    ).register(SpawnManager::OBSTACLES_GROUP)

    if @repeats_this_volley < 3
      @fire_cooldown = REPEAT_COOLDOWN
      @repeats_this_volley += 1
    else
      @repeats_this_volley = 0
      @fire_cooldown = rand(120..160)
    end
  end
end
