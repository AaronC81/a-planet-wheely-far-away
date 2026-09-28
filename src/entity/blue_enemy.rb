class BlueEnemy < Enemy
  IMAGE = AssetLoader.load_image("enemies/blue_ufo.png")

  def initialize(**kw)
    super(
      animations: {
        normal: OZ::Animation.static(IMAGE),
      },
      fire_cooldown: rand(40...90),
      fire_buffer: rand(100...120),
      target_x: rand(900..1400),
      hp: 20,
      **kw
    )
  end

  def fire
    AssetLoader.play_sample("sample/laser_pew.wav")

    EnemyBullet.new(
      animations: {
        normal: OZ::Animation.static(AssetLoader.load_image("particles/blue_bullet.png")),
      },
      position: bounding_box.centre,
      velocity: OZ::Point.new(-2, 0),
    ).register(SpawnManager::OBSTACLES_GROUP)
  end
end
