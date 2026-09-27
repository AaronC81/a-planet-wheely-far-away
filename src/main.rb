require 'gosu'
require 'orange_zest'
OZ = OrangeZest

class Window < OZ::Window
  WIDTH = 1600
  HEIGHT = 900
end

require_relative 'asset_loader'

require_relative 'entity/train_locomotive'

require_relative 'component/track_manager'
require_relative 'component/gun_manager'

class Window < OZ::Window
  def initialize
    super(WIDTH, HEIGHT)

    $speed = 3

    TrackManager.new.register
    GunManager.new.register

    $train = TrainLocomotive.new.register
  end

  def update
    super
  end

  def draw
    super
  end
end

$volume = 0.5

Window.new.show
