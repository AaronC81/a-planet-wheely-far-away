class RapidPickup < Pickup
  def initialize
    image = AssetLoader.load_image("pickup/rapid_pickup.png")
    super(image, RoadManager.rand_y_for_obstacle(image.height))
  end

  def on_pickup
    AssetLoader.play_sample("sample/rapid_start.wav")
    $gun.rapid_fire_remaining_ammo = 45
  end
end
