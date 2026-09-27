class Intro < OZ::Component
  INTRO_GROUP = OZ::Group.new

  class FadeImage < OZ::Entity
    def initialize(image, **kw)
      super(
        animations: {
          normal: OZ::Animation.static(image),
        },
        **kw,
      )
      self.opacity = 0
    end

    def update
      if self.opacity < 1 && !@revealed
        self.opacity += 0.05
      else
        @revealed = true
      end
    end

    def fade_out
      loop do
        self.opacity -= 0.05
        if self.opacity <= 0
          unregister
          break
        end
        OZ::Scheduler.wait 1
      end
    end
  end

  # Preload
  AssetLoader.load_sample("sample/intro/glint.wav")
  AssetLoader.load_sample("sample/intro/hmm.wav")
  AssetLoader.load_sample("sample/intro/ufo.wav")
  AssetLoader.load_sample("sample/intro/alien_speech.wav")
  AssetLoader.load_sample("sample/intro/shock.wav")
  AssetLoader.load_sample("sample/intro/rev.wav")
  AssetLoader.load_sample("sample/intro/rev2.wav")

  def initialize
    INTRO_GROUP.register
  end
  
  def start
    # TODO need a way to cancel
    OZ::Scheduler.start do
      AssetLoader.play_sample("sample/intro/wind_ambiance.wav")
      OZ::Scheduler.wait 60

      show_image "intro/1.png", :centre, :centre, 240

      i = show_image "intro/2.png", 20, 20
      OZ::Scheduler.wait 120
      AssetLoader.play_sample("sample/intro/glint.wav")
      i2 = show_image "intro/2_glimmer.png", 110, 110
      OZ::Scheduler.wait 120
      i3 = show_image "intro/3.png", Window::WIDTH - 570, Window::HEIGHT - 400
      OZ::Scheduler.wait 120
      OZ::Scheduler.start { i.fade_out }
      OZ::Scheduler.start { i2.fade_out }
      OZ::Scheduler.start { i3.fade_out }
      OZ::Scheduler.wait 20

      AssetLoader.play_sample("sample/intro/ufo.wav")
      i = show_image "intro/4.png", 20, 20
      OZ::Scheduler.wait 180
      AssetLoader.play_sample("sample/intro/alien_speech.wav")
      i2 = show_image "intro/4_speech.png", 360, 180
      OZ::Scheduler.wait 180
      i3 = show_image "intro/5.png", Window::WIDTH - 570, Window::HEIGHT - 400
      OZ::Scheduler.wait 120
      OZ::Scheduler.start { i.fade_out }
      OZ::Scheduler.start { i2.fade_out }
      OZ::Scheduler.start { i3.fade_out }
      OZ::Scheduler.wait 20

      AssetLoader.play_sample("sample/intro/enter_car.wav")
      gl = show_image "intro/6_mirror.png", 100, :centre
      OZ::Scheduler.wait 100
      AssetLoader.play_sample("sample/intro/rev.wav")
      i = show_image "intro/6_tacho.png", 800, :centre
      OZ::Scheduler.wait 100
      OZ::Scheduler.start { i.fade_out }
      OZ::Scheduler.start { gl.fade_out }
      OZ::Scheduler.wait 20

      AssetLoader.play_sample("sample/intro/ufo_flight.wav")
      i = show_image "intro/7_ufo.png", 300, 50
      OZ::Scheduler.wait 150
      AssetLoader.play_sample("sample/intro/rev2.wav")
      gl = show_image "intro/7_car.png", 900, 250
      OZ::Scheduler.wait 150
      OZ::Scheduler.start { i.fade_out }
      OZ::Scheduler.start { gl.fade_out }
      OZ::Scheduler.wait 20

      AssetLoader.play_sample("sample/intro/ufo_charge.wav")
      show_image "intro/8.png", :centre, :centre, 180

      AssetLoader.play_sample("sample/intro/ufo_abduct.wav")
      show_image "intro/9.png", :centre, :centre, 300
    end
  end

  def cancel
    # TODO: Untested
    # There are no other scheduled tasks during the intro, so...
    OZ::Scheduler.clear
  end

  def show_image(path, x, y, duration=nil)
    sprite = AssetLoader.load_image(path)

    if x == :centre
      x = (Window::WIDTH - sprite.width) / 2
    end
    if y == :centre
      y = (Window::HEIGHT - sprite.height) / 2
    end

    img = FadeImage.new(sprite, position: OZ::Point.new(x, y)).register(INTRO_GROUP)
    if duration
      OZ::Scheduler.wait duration
      img.fade_out
    end
    img
  end
end
