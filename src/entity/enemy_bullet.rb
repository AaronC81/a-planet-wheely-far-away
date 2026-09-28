class EnemyBullet < OZ::Entity
  BULLET_SPRITE = AssetLoader.load_image("particles/alien_bullet.png")

  def initialize(velocity:, **kw)
    super(
      animations: {
        normal: OZ::Animation.static(BULLET_SPRITE),
      },
      **kw,
    )
    
    @velocity = velocity
  end

  def update
    @position += @velocity
    @position.x -= $speed

    if @position.x + image.width < 0 || @position.x > Window::WIDTH
      unregister
    end
  end
end