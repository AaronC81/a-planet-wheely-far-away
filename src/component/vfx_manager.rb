module VfxManager
  @@effects = []

  Effect = Struct.new('Effect', :image, :lifetime, :duration, :x, :y, :x_velocity, :y_velocity, :rotation, :fade)

  def self.add_effect(image:, duration:, x:, y:, x_velocity: 0, y_velocity: 0, rotation: 0, fade: true)
    @@effects << Effect.new(image, 0, duration, x, y, x_velocity, y_velocity, rotation, fade)
  end

  def self.update
    dt = 1.0 / 60

    @@effects.each do |effect|
      effect.lifetime += dt
      effect.x += effect.x_velocity * dt
      effect.y += effect.y_velocity * dt
    end

    @@effects.reject! { |effect| effect.lifetime > effect.duration }
  end

  def self.draw
    @@effects.each do |effect|
      if effect.fade
        colour = Gosu::Color.rgba(0xFF, 0xFF, 0xFF, lerp(0xFF, 0, effect.lifetime / effect.duration))
      else
        colour = Gosu::Color::WHITE
      end
      effect.image.draw_rot(effect.x, effect.y, 1000, effect.rotation, 0.5, 0.5, 1, 1, colour)
    end
  end

  # https://gist.github.com/JamesMcMahon/3010c6e514f6828199878788541e7a75
  def self.lerp(start, stop, step)
    return start if start == stop # Avoid div0 for only one image

    (stop * step) + (start * (1.0 - step))
  end
end
