class PlayerCar < OZ::Entity
  MAX_HP = 5

  IMAGE = AssetLoader.load_image("player_car.png")
  IMAGE_DAMAGED = AssetLoader.load_image("player_car_damaged.png")
  IMAGE_CRITICAL = AssetLoader.load_image("player_car_critical.png")

  VERTICAL_CENTRE = (Window::HEIGHT - IMAGE.height) / 2

  VERTICAL_SPEED = 6

  def initialize(**kw)
    super(
      position: OZ::Point.new(50, VERTICAL_CENTRE),
      animations: {
        normal: OZ::Animation.static(IMAGE),
        damaged: OZ::Animation.static(IMAGE_DAMAGED),
        critical: OZ::Animation.static(IMAGE_CRITICAL),
      },
      **kw
    )

    @hp = 5
    @invulnerability_timer = 0
    @gone = false
  end

  attr_accessor :hp

  def update
    return if @hp == 0

    if @hp == 1
      self.animation = :critical
    elsif @hp <= 3
      self.animation = :damaged
    else
      self.animation = :normal
    end

    if @invulnerability_timer > 0
      @invulnerability_timer -= 1

      if (@invulnerability_timer / 20) % 2 == 0
        self.opacity = 0.5
      else
        self.opacity = 0.25
      end
    else
      self.opacity = 1
    end

    vertical_velocity = 0
    if Gosu.button_down?(Gosu::KB_W)
      vertical_velocity -= VERTICAL_SPEED
    end
    if Gosu.button_down?(Gosu::KB_S)
      vertical_velocity += VERTICAL_SPEED
    end

    new_y = self.position.y + vertical_velocity
    if new_y < RoadManager::BUILDINGS_START || new_y > Window::HEIGHT - IMAGE.height
      vertical_velocity = 0
    end

    self.position.y += vertical_velocity
    if vertical_velocity > 0
      self.rotation = 2
    elsif vertical_velocity < 0
      self.rotation = -2
    else
      self.rotation = 0
    end
  end

  def draw
    super unless @gone
  end

  def dead?
    @hp == 0
  end

  def hit
    if @invulnerability_timer <= 0
      # TODO: death logic
      # TODO: animation or something
      @hp -= 1
      @hp = 0 if @hp < 0

      # Just died
      if dead?
        $speed = 0
        OZ::Scheduler.start do
          8.times do
            OZ::Scheduler.wait 10
            VfxManager.add_effect(
              image: AssetLoader.load_image("particles/smoke.png"),
              x: bounding_box.origin.x + rand(0..bounding_box.width),
              y: bounding_box.origin.y + rand(0..bounding_box.height),
              rotation: rand(0...360),
              duration: 0.3
            )
            AssetLoader.play_sample("sample/poof.wav")
          end

          OZ::Scheduler.wait 20

          @gone = true
          4.times do
            VfxManager.add_effect(
              image: AssetLoader.load_image("particles/smoke.png"),
              x: bounding_box.origin.x + rand(0..bounding_box.width),
              y: bounding_box.origin.y + rand(0..bounding_box.height),
              rotation: rand(0...360),
              duration: 1
            )
          end
          AssetLoader.play_sample("sample/poof.wav")
        
          $banner.show_banner(AssetLoader.load_image("text/game_over.png")) do
            $fade.fade do
              $state = :main_menu
            end
          end
        end
      else
        5.times do
          VfxManager.add_effect(
            image: AssetLoader.load_image("particles/hit_sparks.png"),
            x: bounding_box.origin.x + rand(0..bounding_box.width),
            y: bounding_box.origin.y + rand(0..bounding_box.height),
            rotation: rand(0...360),
            duration: 0.75,
          )
        end
      end

      AssetLoader.play_sample("sample/car_hit.wav")

      @invulnerability_timer = 100
    end
  end
end
