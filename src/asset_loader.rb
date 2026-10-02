module AssetLoader
  @@images = {}
  @@fonts = {}
  @@samples = {}
  @@songs = {}

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

  def self.load_font(path, size)
    full_path = File.join(__dir__, '..', 'res', *path)
    key = [full_path, size]
    if @@fonts.has_key?(key)
      @@fonts[key]
    else
      @@fonts[key] = Gosu::Font.new(size, name: full_path)
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

  def self.load_song(*path)
    full_path = File.join(__dir__, '..', 'res', *path)
    if @@songs.has_key?(full_path)
      @@songs[full_path]
    else
      @@songs[full_path] = Gosu::Song.new(full_path)
    end
  end

  def self.play_song(*path, volume: 1.0)
    return unless $music

    song = load_song(*path)
    song.volume = $volume * volume
    song.play(true)
  end
end
