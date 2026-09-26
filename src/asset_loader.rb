module AssetLoader
  @@images = {}
  @@fonts = {}
  @@samples = {}

  def self.load_image(*path, retro: false)
    full_path = File.join(__dir__, '..', 'res', *path)
    if @@images.has_key?(full_path)
      @@images[full_path]
    else
      @@images[full_path] = Gosu::Image.new(full_path, retro: retro)
    end
  end

  def self.load_system_font(name, size)
    key = [name, size]
    if @@fonts.has_key?(key)
      @@fonts[key]
    else
      @@fonts[key] = Gosu::Font.new(size, name: name)
    end
  end

  def self.load_sample(*path)
    full_path = File.join(__dir__, '..', 'res', *path)
    if @@samples.has_key?(full_path)
      @@samples[full_path]
    else
      @@samples[full_path] = Gosu::Sample.new(full_path)
    end
  end

  def self.play_sample(*path, volume: 1.0)
    load_sample(*path).play($volume * volume)
  end
end
