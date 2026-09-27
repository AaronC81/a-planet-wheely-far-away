class GunManager < OZ::Component
  MAX_AMMO = 6

  RecentShot = Struct.new('RecentShot', :origin, :target, :age)

  CYLINDER_SPRITE = AssetLoader.load_image("ui/cylinder.png")
  ROUND_LIVE_SPRITE = AssetLoader.load_image("ui/round_live.png")
  ROUND_SPENT_SPRITE = AssetLoader.load_image("ui/round_spent.png")

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
  end

  def update
    @recent_shots.each do |shot|
      # TODO: This will need to change velocity based on the direction the "camera" is moving
      shot.origin.x -= $speed
      shot.target.x -= $speed

      shot.age += 1
    end
    @recent_shots.reject! { |shot| shot.age > 10 }

    if OZ::Input.click?
      OZ::Input.clear_click

      if @ammo > 0
        # Cancel reload
        @is_reloading = false

        @ammo -= 1

        # TODO: iterate "shootables" to find if we hit one, somehow (maybe in a group?)
        @recent_shots << RecentShot.new($train.bounding_box.center, OZ::Input.cursor, 0)

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
        OZ::Scheduler.wait 15
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
      end
    end
  end

  def draw
    CYLINDER_SPRITE.draw(30, 30, 100000)
    ROUND_POSITIONS.each.with_index do |pos, i|
      spent_ammo = MAX_AMMO - @ammo

      sprite = i >= spent_ammo ? ROUND_LIVE_SPRITE : ROUND_SPENT_SPRITE
      sprite.draw(30 + pos.x, 30 + pos.y, 100000)
    end

    @recent_shots.each do |shot|
      Gosu.draw_line(shot.origin.x, shot.origin.y, Gosu::Color::YELLOW, shot.target.x, shot.target.y, Gosu::Color::YELLOW)
      Gosu.draw_rect(shot.target.x - 4, shot.target.y - 4, 9, 9, Gosu::Color::YELLOW)
    end
  end
end
