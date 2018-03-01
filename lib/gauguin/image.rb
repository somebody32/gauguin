require "shellwords"

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
      output = `convert #{path.shellescape} -format %c -alpha on histogram:info:-`
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
      output = `identify #{path.shellescape}`.split(' ')
      dimensions = output[2].split('x')
      self.height, self.width = dimensions.map(&:to_i)
    end
  end
end

