class GunManager < OZ::Component
  SHOOTABLES_GROUP = OZ::Group.new

  MAX_AMMO = 6

  RecentShot = Struct.new('RecentShot', :origin, :target, :age)

  CYLINDER_SPRITE = AssetLoader.load_image("ui/cylinder.png")
  ROUND_LIVE_SPRITE = AssetLoader.load_image("ui/round_live.png")
  ROUND_SPENT_SPRITE = AssetLoader.load_image("ui/round_spent.png")

  HEART_FULL_SPRITE = AssetLoader.load_image("ui/heart_full.png")
  HEART_EMPTY_SPRITE = AssetLoader.load_image("ui/heart_empty.png")

  EXPORT_SCALE = 0.35
  # All centres
  ROUND_POSITIONS = [
    OZ::Point.new(118 * EXPORT_SCALE, 21 * EXPORT_SCALE),
    OZ::Point.new(200 * EXPORT_SCALE, 71 * EXPORT_SCALE),
    OZ::Point.new(200 * EXPORT_SCALE, 165 * EXPORT_SCALE),
    OZ::Point.new(118 * EXPORT_SCALE, 213 * EXPORT_SCALE),
    OZ::Point.new(34 * EXPORT_SCALE, 165 * EXPORT_SCALE),
    OZ::Point.new(34 * EXPORT_SCALE, 71 * EXPORT_SCALE),
  ]

  # Preload
  AssetLoader.load_sample("sample/revolver_reload_start.wav")
  AssetLoader.load_sample("sample/revolver_reload_each.wav")
  AssetLoader.load_sample("sample/revolver_spin.wav")
  AssetLoader.load_sample("sample/revolver_shot.wav")
  AssetLoader.load_sample("sample/revolver_empty.wav")

  def initialize
    @recent_shots = []
    @ammo = MAX_AMMO

    @is_reloading = false

    @cylinder_angle = 0

    SHOOTABLES_GROUP.register
  end

  def update
    @recent_shots.each do |shot|
      shot.origin.x -= $speed
      shot.target.x -= $speed

      shot.age += 1
    end
    @recent_shots.reject! { |shot| shot.age > 2 }

    if OZ::Input.click?
      OZ::Input.clear_click

      if @ammo > 0
        # Cancel reload
        @is_reloading = false
        @cylinder_angle = 0

        @ammo -= 1

        check_hit(OZ::Input.cursor)
        @recent_shots << RecentShot.new($player.bounding_box.center, OZ::Input.cursor, 0)

        AssetLoader.play_sample("sample/revolver_shot.wav")
      else
        AssetLoader.play_sample("sample/revolver_empty.wav")
      end
    end

    if Gosu.button_down?(Gosu::KB_R) && !@is_reloading && @ammo < MAX_AMMO
      @is_reloading = true

      # Fixes exploit where you could hold R while firing to fast-reload.
      # Ideally we'd just be able to cancel tasks, but...
      reload_id = rand(1..1000)
      @reload_id = reload_id

      OZ::Scheduler.start do
        # Because the reload can be cancelled, we need to check it hasn't been after each wait.
        AssetLoader.play_sample("sample/revolver_reload_start.wav")

        # Fixed delay - discourages reloading after every shot, like flipping the cylinder
        15.times do
          @cylinder_angle += 2
          OZ::Scheduler.wait 1
        end
        next unless @is_reloading && reload_id == @reload_id

        while @ammo < MAX_AMMO
          OZ::Scheduler.wait 15
          next unless @is_reloading && reload_id == @reload_id

          AssetLoader.play_sample("sample/revolver_reload_each.wav")
          @ammo += 1
        end
  
        @is_reloading = false

        OZ::Scheduler.wait 3
        AssetLoader.play_sample("sample/revolver_spin.wav")

        # Spin animation
        15.times do
          @cylinder_angle += 80
          OZ::Scheduler.wait 1
        end

        @cylinder_angle = 270
        OZ::Scheduler.wait 1
        @cylinder_angle = 320
        OZ::Scheduler.wait 1
        @cylinder_angle = 340
        OZ::Scheduler.wait 1
        @cylinder_angle = 350
        OZ::Scheduler.wait 1
        @cylinder_angle = 355
        OZ::Scheduler.wait 1
        @cylinder_angle = 358
        OZ::Scheduler.wait 1
        @cylinder_angle = 0
      end
    end
  end

  def check_hit(point)
    SHOOTABLES_GROUP.items.each do |shootable|
      if shootable.bounding_box.point_inside?(point)
        shootable.inflict_gun_damage(5)

        VfxManager.add_effect(
          image: AssetLoader.load_image("particles/hit_sparks.png"),
          x: point.x,
          y: point.y,
          rotation: rand(0...360),
          duration: 0.25,
        )

        AssetLoader.play_sample("sample/revolver_hit_#{rand(1..4)}.wav")
      end
    end

    SHOOTABLES_GROUP.items.reject!(&:dead?)
  end

  def draw
    x = 30
    y = 30

    Gosu.rotate(@cylinder_angle, x + CYLINDER_SPRITE.width / 2, y + CYLINDER_SPRITE.height / 2) do
      CYLINDER_SPRITE.draw(x, y, 100000)
      ROUND_POSITIONS.each.with_index do |pos, i|
        spent_ammo = MAX_AMMO - @ammo

        sprite = i >= spent_ammo ? ROUND_LIVE_SPRITE : ROUND_SPENT_SPRITE
        sprite.draw(x + pos.x, y + pos.y, 100000)
      end
    end

    @recent_shots.each do |shot|
      Gosu.draw_line(shot.origin.x, shot.origin.y, Gosu::Color::YELLOW, shot.target.x, shot.target.y, Gosu::Color::YELLOW, 100000)
    end

    # We're drawing UI so we might as well be responsible for HP as well. Who cares really
    lost_hp = PlayerCar::MAX_HP - $player.hp
    PlayerCar::MAX_HP.times do |i|
      sprite = lost_hp > i ? HEART_EMPTY_SPRITE : HEART_FULL_SPRITE
      sprite.draw(Window::WIDTH - 30 - 100 * (i + 1), y, 100000)
    end
  end
end
