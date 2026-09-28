class EnemyBullet < OZ::Entity
  def initialize(velocity:, **kw)
    super(**kw)
    
    @velocity = velocity
  end

  def update
    @position += @velocity
    @position.x -= $speed
  end
end