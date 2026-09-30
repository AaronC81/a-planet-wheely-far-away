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
require_relative 'entity/blue_enemy'
require_relative 'entity/green_enemy'
require_relative 'entity/red_enemy'
require_relative 'entity/pickup'
require_relative 'entity/rapid_pickup'
require_relative 'entity/heal_pickup'

require_relative 'component/road_manager'
require_relative 'component/gun_manager'
require_relative 'component/spawn_manager'
require_relative 'component/vfx_manager'
require_relative 'component/intro'
require_relative 'component/main_menu'

require_relative 'ext/orange_zest'

require_relative 'game'
Game.reset

class Window < OZ::Window
  def initialize
    super(WIDTH, HEIGHT)

    @main_menu = MainMenu.new do
      Game.reset
      @state = :game
    end

    @state = :intro
    @intro = Intro.new

    # TODO: wire this up in some sensible way
    @intro.start do
      @state = :main_menu
    end
  end

  def update
    VfxManager.update
    active_component.update

    super
  end

  def draw
    VfxManager.draw
    active_component.draw

    super
  end

  def active_component
    case @state
    when :intro
      @intro
    when :main_menu
      @main_menu
    when :game
      Game
    end
  end
end

$volume = 0.5

Window.new.show
