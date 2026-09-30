class PinkEnemy < Enemy
  IMAGE = AssetLoader.load_image("enemies/pink_ufo.png")

  def initialize(**kw)
    super(
      animations: {
        normal: OZ::Animation.static(IMAGE),
      },
      fire_cooldown: rand(120...180),
      fire_buffer: rand(40...60),
      target_x: rand(1200..1400),
      hp: 20,
      **kw
    )
  end

  def fire
    AssetLoader.play_sample("sample/laser_pew_2.wav")

    angle = Gosu.angle(
      bounding_box.centre.x, bounding_box.centre.y,
      $player.bounding_box.centre.x, $player.bounding_box.centre.y,
    )

    x_velocity = Gosu.offset_x(angle, 2)
    y_velocity = Gosu.offset_y(angle, 2)

    EnemyBullet.new(
      animations: {
        normal: OZ::Animation.static(AssetLoader.load_image("particles/pink_bullet.png")),
      },
      position: bounding_box.centre,
      velocity: OZ::Point.new(x_velocity, y_velocity),
    ).register(SpawnManager::OBSTACLES_GROUP)
  end
end
