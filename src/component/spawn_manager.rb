class SpawnManager < OZ::Component
  OBSTACLES_GROUP = OZ::Group.new

  def initialize
    @timer = 30

    OBSTACLES_GROUP.register
  end

  def update
    OBSTACLES_GROUP.items.each do |obstacle|
      obstacle.check_collision
    end

    @timer -= 1
    if @timer <= 0
      image = AssetLoader.load_image('obstacles/wall.png')
      Obstacle.new(
        image,
        RoadManager.rand_y_for_obstacle(image.height),
      ).register(OBSTACLES_GROUP)
      @timer = 30
    end
  end
end
