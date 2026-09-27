class GunManager < OZ::Component
  MAX_AMMO = 6

  RecentShot = Struct.new('RecentShot', :origin, :target, :age)

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
    # TODO: temporary, better UI later
    font = AssetLoader.load_system_font("Arial", 24)
    font.draw_text("#{@ammo}/#{MAX_AMMO}", 20, 20, 100)
    if @is_reloading
      font.draw_text("Reloading", 20, 50, 100)
    end

    @recent_shots.each do |shot|
      Gosu.draw_line(shot.origin.x, shot.origin.y, Gosu::Color::YELLOW, shot.target.x, shot.target.y, Gosu::Color::YELLOW)
      Gosu.draw_rect(shot.target.x - 4, shot.target.y - 4, 9, 9, Gosu::Color::YELLOW)
    end
  end
end
