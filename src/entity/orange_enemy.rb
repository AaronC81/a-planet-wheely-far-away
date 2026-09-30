class OrangeEnemy < Enemy
  IMAGE = AssetLoader.load_image("enemies/orange_ufo.png")

  def initialize(**kw)
    super(
      animations: {
        normal: OZ::Animation.static(IMAGE),
      },
      fire_cooldown: rand(100...150),
      fire_buffer: rand(50...100),
      target_x: rand(1200..1400),
      hp: 25,
      **kw
    )
  end

  def fire
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
end
