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

    def color_histogram
      output = run_in_shell(
        "convert",
        path,
        "-posterize", "#{Gauguin.configuration.posterize_level}",
        "-format", "%c",
        "-alpha", "on",
        "histogram:info:-"
      )

      output.lines.map do |line|
        data = line.split(' ')
        count = data.shift
        data.pop(2)

        rgb = data.join('').match(RGBA_REGEX)

        [count.gsub(':', '').to_i, rgb[1..rgb.size-1].map(&:to_i)]
      end
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
      stdout_or_stderr, status = Open3.capture2e(*args)
      raise(Gauguin::Error, stdout_or_stderr) if status != 0

      stdout_or_stderr
    end
  end
end

