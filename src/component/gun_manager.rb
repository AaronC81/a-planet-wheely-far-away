class GunManager < OZ::Component
  SHOOTABLES_GROUP = OZ::Group.new

  MAX_AMMO = 6

  RecentShot = Struct.new('RecentShot', :origin, :target, :age)

  CYLINDER_SPRITE = AssetLoader.load_image("ui/cylinder.png")
  ROUND_LIVE_SPRITE = AssetLoader.load_image("ui/round_live.png")
  ROUND_SPENT_SPRITE = AssetLoader.load_image("ui/round_spent.png")

  DRUM_SPRITE = AssetLoader.load_image("ui/drum_mag.png")
  DRUM_AMMO_FONT = AssetLoader.load_font("font/Ranchers-Regular.ttf", 56)

  HEART_FULL_SPRITE = AssetLoader.load_image("ui/heart_full.png")
  HEART_EMPTY_SPRITE = AssetLoader.load_image("ui/heart_empty.png")

  SPEEDOMETER_SPRITE = AssetLoader.load_image("ui/speedometer.png", retro: true)
  MOTHERSHIP_HP_SPRITE = AssetLoader.load_image("ui/mothership_hp.png", retro: true)

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

    @rapid_fire_remaining_ammo = 0
    @rapid_fire_cooldown = 0
  end

  attr_accessor :rapid_fire_remaining_ammo

  def update
    SHOOTABLES_GROUP.update
    SHOOTABLES_GROUP.items.reject!(&:dead?)

    @recent_shots.each do |shot|
      shot.origin.x -= $speed
      shot.target.x -= $speed

      shot.age += 1
    end
    @recent_shots.reject! { |shot| shot.age > 2 }

    if @rapid_fire_cooldown > 0
      @rapid_fire_cooldown -= 1
    end

    if OZ::Input.click? || (@rapid_fire_remaining_ammo > 0 && Gosu.button_down?(Gosu::MS_LEFT) && @rapid_fire_cooldown == 0)
      OZ::Input.clear_click

      if @rapid_fire_remaining_ammo > 0
        @rapid_fire_cooldown = 7
      end

      if @ammo > 0 || @rapid_fire_remaining_ammo > 0
        # Cancel reload
        @is_reloading = false
        @cylinder_angle = 0

        if @rapid_fire_remaining_ammo > 0
          AssetLoader.play_sample("sample/rapid_shot.wav")
        else
          AssetLoader.play_sample("sample/revolver_shot.wav")
        end

        if @rapid_fire_remaining_ammo > 0
          @rapid_fire_remaining_ammo -= 1

          if @rapid_fire_remaining_ammo == 0
            AssetLoader.play_sample("sample/rapid_end.wav")

            # Free reload when leaving rapid
            @ammo = 6
          end
        else
          @ammo -= 1
        end

        check_hit(OZ::Input.cursor)
        @recent_shots << RecentShot.new($player.bounding_box.center, OZ::Input.cursor, 0)
      else
        AssetLoader.play_sample("sample/revolver_empty.wav")
      end
    end

    if Gosu.button_down?(Gosu::KB_R) && !@is_reloading && @ammo < MAX_AMMO && @rapid_fire_remaining_ammo == 0
      @is_reloading = true

      # Fixes exploit where you could hold R while firing to fast-reload.
      # Ideally we'd just be able to cancel tasks, but...
      reload_id = rand(1..1000)
      @reload_id = reload_id

      OZ::Scheduler.start do
        # Because the reload can be cancelled, we need to check it hasn't been after each wait.
        AssetLoader.play_sample("sample/revolver_reload_start.wav")

        # Fixed delay - discourages reloading after every shot, like flipping the cylinder
        7.times do
          @cylinder_angle += 4
          OZ::Scheduler.wait 1
        end
        next unless @is_reloading && reload_id == @reload_id

        while @ammo < MAX_AMMO
          OZ::Scheduler.wait 8
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
  end

  def draw
    SHOOTABLES_GROUP.draw

    x = 30
    y = 30
    
    # We're drawing UI so we might as well be responsible for HP as well. Who cares really
    if $assist_mode
      image = AssetLoader.load_image("ui/hp_assist.png")
      image.draw(x, y, 0)

      lost_hp = PlayerCar::ASSIST_FAKE_MAX_HP - $player.hp
      DRUM_AMMO_FONT.draw_text_rel(lost_hp.to_s, x + image.width / 2, y + image.height / 2 - 10, 100001, 0.5, 0.5, 1, 1, Gosu::Color::WHITE)
    else
      clamped_hp = $player.hp
      clamped_hp = 5 if clamped_hp > 5
      clamped_hp = 0 if clamped_hp < 0
        
      image = AssetLoader.load_image("ui/hp_#{clamped_hp}.png")
      image.draw(x, y, 0)
    end

    x = 180
    y += 10

    if @rapid_fire_remaining_ammo > 0
      DRUM_SPRITE.draw(x, y, 100000)

      DRUM_AMMO_FONT.draw_text_rel(@rapid_fire_remaining_ammo.to_s, x + DRUM_SPRITE.width / 2, y + DRUM_SPRITE.height / 2, 100001, 0.5, 0.5, 1, 1, Gosu::Color::WHITE)
    else
      Gosu.rotate(@cylinder_angle, x + CYLINDER_SPRITE.width / 2, y + CYLINDER_SPRITE.height / 2) do
        CYLINDER_SPRITE.draw(x, y, 100000)
        ROUND_POSITIONS.each.with_index do |pos, i|
          spent_ammo = MAX_AMMO - @ammo

          sprite = i >= spent_ammo ? ROUND_LIVE_SPRITE : ROUND_SPENT_SPRITE
          sprite.draw(x + pos.x, y + pos.y, 100000)
        end
      end
    end

    @recent_shots.each do |shot|
      Gosu.draw_line(shot.origin.x, shot.origin.y, Gosu::Color::YELLOW, shot.target.x, shot.target.y, Gosu::Color::YELLOW, 100000)
    end

    # And speed! Why not...
    SPEEDOMETER_SPRITE.draw(Window::WIDTH - SPEEDOMETER_SPRITE.width - 50, 50, 10000)
    font = AssetLoader.load_font("font/DSEG7ClassicMini-Regular.ttf", 55)
    font.draw_text_rel($speed_mph.to_s, Window::WIDTH - SPEEDOMETER_SPRITE.width + 55, 70, 10001, 1.0, 0, 1.0, 1.0, Gosu::Color.argb(255, 255, 167, 74))

    # Screw it, mothership HP while we're at it, I guess ;)
    if $mothership && $mothership.hp > 0
      MOTHERSHIP_HP_SPRITE.draw((Window::WIDTH - MOTHERSHIP_HP_SPRITE.width) / 2, 50, 10000)
      
      hp_bar_width = MOTHERSHIP_HP_SPRITE.width - 30
      Gosu.draw_rect((Window::WIDTH - hp_bar_width) / 2, 90, hp_bar_width, 40, Gosu::Color::WHITE, 10000)

      hp_ratio = $mothership.hp / $mothership.max_hp.to_f
      Gosu.draw_rect((Window::WIDTH - hp_bar_width) / 2, 90, hp_bar_width * hp_ratio, 40, Gosu::Color::RED, 10000)
    end
  end
end
