class HealPickup < Pickup
  def initialize
    image = AssetLoader.load_image("pickup/heal_pickup.png")
    super(image, RoadManager.rand_y_for_obstacle(image.height))
  end

  def on_pickup
    AssetLoader.play_sample("sample/heal.wav")
    $player.hp += 1
    $player.hp = PlayerCar::MAX_HP if $player.hp > PlayerCar::MAX_HP
  end
end
