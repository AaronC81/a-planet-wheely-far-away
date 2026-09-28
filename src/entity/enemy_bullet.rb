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
  end
end