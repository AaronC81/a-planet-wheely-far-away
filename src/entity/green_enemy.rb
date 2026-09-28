class GreenEnemy < Enemy
  IMAGE = AssetLoader.load_image("enemies/green_ufo.png")

  def initialize(**kw)
    super(
      animations: {
        normal: OZ::Animation.static(IMAGE),
      },
      fire_cooldown: rand(30...50),
      fire_buffer: rand(50...70),
      target_x: rand(1200..1400),
      hp: 10,
      **kw
    )
  end

  def fire
    AssetLoader.play_sample("sample/laser_small_pew.wav")

    EnemyBullet.new(
      animations: {
        normal: OZ::Animation.static(AssetLoader.load_image("particles/green_bullet.png")),
      },
      position: bounding_box.centre,
      velocity: OZ::Point.new(-2.5, [true, false].sample ? rand(-0.6..-0.4) : rand(0.4..0.6)),
    ).register(SpawnManager::OBSTACLES_GROUP)

    @fire_cooldown = rand(30..50)
  end
end
