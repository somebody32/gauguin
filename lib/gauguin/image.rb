require 'rmagick'
require 'mini_magick'
require 'forwardable'

module MiniMagick
  class Image
    def histogram
      color = run_command("convert", path, "-format", "%c", "-alpha", "on", "histogram:info:")
      regex = /\((\S+),(\S+),(\S+),(\S+)\)/
      color.split("\n").map do |row|
        data = row.split(' ')
        count = data.shift
        data.pop
        data.pop
        rgb = data.join('').match(regex).to_a
        rgb.shift

        [count.gsub(':', '').to_i, rgb.map(&:to_i)]
      end

    end
  end
end

module Gauguin
  class Image
    extend Forwardable
    attr_accessor :image, :mimage
    delegate [:write] => :image

    def initialize(path = nil)
      return unless path

      list = Magick::ImageList.new(path)
      self.image = list.first
      self.mimage = MiniMagick::Image.open(path)
    end

    def self.blank(columns, rows)
      blank_image = Image.new
      transparent_white = Magick::Pixel.new(255, 255, 255, Pixel::MAX_TRANSPARENCY)
      blank_image.image = Magick::Image.new(columns, rows) do
        self.background_color = transparent_white
      end
      blank_image
    end

    def pixel(magic_pixel)
      Pixel.new(magic_pixel)
    end

    def color_histogram
      mimage.histogram
    end

    def rows
      mimage.height
    end

    def columns
      mimage.width
    end

    def pixel_color(row, column, *args)
      magic_pixel = self.image.pixel_color(row, column, *args)
      pixel(magic_pixel)
    end

    class Pixel
      MAX_CHANNEL_VALUE = 257
      MAX_TRANSPARENCY = 65535

      def initialize(magic_pixel)
        @magic_pixel = magic_pixel
      end

      def transparent?
        @magic_pixel.opacity >= MAX_TRANSPARENCY
      end

      def to_rgb
        [:red, :green, :blue].map do |color|
          @magic_pixel.send(color) / MAX_CHANNEL_VALUE
        end
      end
    end
  end
end

