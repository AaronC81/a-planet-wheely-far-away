require 'gosu'
require 'orange_zest'
OZ = OrangeZest

class Window < OZ::Window
  WIDTH = 1600
  HEIGHT = 900
end

require_relative 'asset_loader'

class Window < OZ::Window
  def initialize
    super(WIDTH, HEIGHT)
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
