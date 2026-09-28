require 'gosu'
require 'orange_zest'
OZ = OrangeZest

class Window < OZ::Window
  WIDTH = 1600
  HEIGHT = 900
end

require_relative 'asset_loader'

require_relative 'entity/player_car'
require_relative 'entity/obstacle'
require_relative 'entity/enemy_bullet'
require_relative 'entity/enemy'

require_relative 'component/road_manager'
require_relative 'component/gun_manager'
require_relative 'component/spawn_manager'
require_relative 'component/vfx_manager'
require_relative 'component/intro'

class Window < OZ::Window
  def initialize
    super(WIDTH, HEIGHT)

    $speed = 8

    RoadManager.new.register
    GunManager.new.register
    SpawnManager.new.register

    # TODO: wire this up in some sensible way
    # Intro.new.start

    $player = PlayerCar.new.register
  end

  def update
    VfxManager.update
    super
  end

  def draw
    VfxManager.draw
    super
  end
end

$volume = 0.5

Window.new.show
