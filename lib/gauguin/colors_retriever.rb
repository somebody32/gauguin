module Gauguin
  class ColorsRetriever
    def initialize(image)
      @image = image
    end

    def colors
      colors = Hash.new(0)

      histogram = @image.color_histogram

      non_transparent = histogram.reject { |_, rgba| rgba[3].zero? }
      non_transparent_count = non_transparent.reduce(0) { |s, p| s + p[0] }

      non_transparent.each do |count, rgba|
        red, green, blue = rgba
        percentage = count.to_f / non_transparent_count

        color = Gauguin::Color.new(red, green, blue)

        # histogram can contain different magic pixels for
        # the same colors with different opacity
        colors[color] += percentage
      end

      colors
    end
  end
end
