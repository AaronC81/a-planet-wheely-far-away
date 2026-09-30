class MothershipEnemy < Enemy
  # TODO: constant Y for this one
  # TODO: don't tilt when entering

  IMAGE = AssetLoader.load_image("enemies/mothership.png")

  def initialize(**kw)
    super(
      animations: {
        normal: OZ::Animation.static(IMAGE),
      },
      fire_cooldown: rand(30),
      fire_buffer: 240,
      target_x: 1100,
      hp: 500, # TODO - balance w/ rapid
      **kw
    )
  end

  def fire
    # TODO: lots of different firing patterns

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
