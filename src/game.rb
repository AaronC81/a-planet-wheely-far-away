module Game
  def self.reset
    $speed = 8

    $road = RoadManager.new
    $gun = GunManager.new
    $spawn = SpawnManager.new
    $banner = BannerManager.new

    $player = PlayerCar.new

    GunManager::SHOOTABLES_GROUP.items.clear
    SpawnManager::OBSTACLES_GROUP.items.clear

    AssetLoader.play_song("song/game.wav", volume: 0.25)
  end
  
  def self.components
    [$road, $spawn, $gun, $player, $banner]
  end

  def self.update
    components.each(&:update)
  end

  def self.draw
    components.each(&:draw)
  end
end
