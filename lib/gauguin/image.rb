require "open3"

module Gauguin
  class Image
    attr_accessor :height, :width
    RGBA_REGEX = /\((\S+),(\S+),(\S+),(\S+)\)/

    def initialize(path = nil)
      return unless path
      self.path = path
      identify!(path)
    end

    def color_histogram(top_left_pixel: false)
      trimmed_path = top_left_pixel ? "#{path}[1x1+0+0]" : path
      posterize = if Gauguin.configuration.posterize_level
        ["-posterize", "#{Gauguin.configuration.posterize_level}"]
      else
        []
      end

      output = run_in_shell(
        "convert",
        trimmed_path,
        *posterize,
        "-format", "%c",
        "-alpha", "on",
        "histogram:info:-"
      )

      output.lines.map do |line|
        data = line.split(' ')
        count = data.shift
        data.pop(2)

        rgb = data.join('').match(RGBA_REGEX)

        [count.delete(':').to_i, rgb[1..rgb.size-1].map(&:to_i)]
      end
    end

    def background_color
      color_histogram(top_left_pixel: true)[0][1]
    end

    private

    attr_accessor :path

    def identify!(path)
      output = run_in_shell(
        "identify",
        "-format", "%wx%h",
        path
      )

      dimensions = output.split('x')
      self.height, self.width = dimensions.map(&:to_i)
    end

    def run_in_shell(*args)
      stdout, status = Open3.capture2(*args)
      raise(Gauguin::Error, stdout) if status != 0

      stdout
    end
  end
end

