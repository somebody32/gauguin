module Gauguin
  class ColorsRetriever
    def initialize(image)
      @image = image
    end

    def colors
      colors = Hash.new(0)

      histogram = @image.color_histogram
      image_size = @image.width * @image.height

      histogram.each do |count, rgba|
        red, green, blue, opacity = rgba
        percentage = count.to_f / image_size

        transparent = opacity.zero?

        color = Gauguin::Color.new(red, green, blue, transparent)

        # histogram can contain different magic pixels for
        # the same colors with different opacity
        colors[color] += percentage
      end

      colors
    end
  end
end
