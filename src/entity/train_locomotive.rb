# TODO: Add carriages too
class TrainLocomotive < OZ::Entity
  IMAGE = AssetLoader.load_image("locomotive.png")

  VERTICAL_CENTRE = (Window::HEIGHT - IMAGE.height) / 2

  def initialize(**kw)
    super(
      position: OZ::Point.new(50, VERTICAL_CENTRE),
      animations: {
        normal: OZ::Animation.static(IMAGE)
      },
      **kw
    )
  end
end
