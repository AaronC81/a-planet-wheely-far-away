class PinkEnemy < Enemy
  IMAGE = AssetLoader.load_image("enemies/pink_ufo.png")

  def initialize(**kw)
    super(
      animations: {
        normal: OZ::Animation.static(IMAGE),
      },
      fire_cooldown: rand(50...70),
      fire_buffer: rand(40...60),
      target_x: rand(1200..1400),
      hp: 15,
      **kw
    )

    @target_y = RoadManager.rand_y_for_obstacle(IMAGE.height)
  end

  def update
    super

    distance = (position.y - @target_y).abs

    if distance < 20
      @target_y = RoadManager.rand_y_for_obstacle(IMAGE.height)
    elsif position.y > @target_y
      position.y -= 1
    elsif position.y < @target_y
      position.y += 1
    end
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
