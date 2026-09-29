module Game
  def self.reset
    $speed = 8

    @road = RoadManager.new
    @gun = GunManager.new
    @spawn = SpawnManager.new

    $player = PlayerCar.new
  end
  
  def self.components
    [@road, @gun, @spawn, $player]
  end

  def self.update
    components.each(&:update)
  end

  def self.draw
    components.each(&:draw)
  end
end
