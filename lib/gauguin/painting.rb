module Gauguin
  class Painting
    attr_reader :color_count, :background_color, :colors_above_noise_level

    def initialize(path)
      @image ||= Gauguin::Image.new(path)
      @colors_retriever = Gauguin::ColorsRetriever.new(@image)
      @colors_limiter = Gauguin::ColorsLimiter.new
      @noise_reducer = Gauguin::NoiseReducer.new
      @colors_clusterer = Gauguin::ColorsClusterer.new
    end

    def palette
      @palette ||= begin
        debug_mode = Gauguin.configuration.debug
        colors = @colors_retriever.colors
        @color_count = colors.size
        puts "Colors total: #{colors.size}" if debug_mode

        colors = @colors_limiter.call(colors)
        puts "Colors after limitation: #{colors.size}" if debug_mode

        nl = Gauguin.configuration.noise_level_threshold
        @colors_above_noise_level = @colors_clusterer.above_threshold(colors, nl)
        puts "Colors more than #{nl*100}%: #{colors_above_noise_level}" if debug_mode

        colors_clusters = @colors_clusterer.clusters(colors)
        puts "Colors clusters: #{colors_clusters.size}" if debug_mode
        dominant_colors = @noise_reducer.call(colors_clusters)

        @background_color = background_color_from_palette(dominant_colors)

        dominant_colors
      end
    end

    private

    def background_color_from_palette(dominant_colors)
      red, green, blue, opacity = @image.background_color
      background_color = Gauguin::Color.new(red, green, blue, opacity.zero?)

      background_from_dominant = dominant_colors.keys.each_with_object({}) do |color, accum|
        distance = color.distance(background_color)
        accum[color] = distance if distance < Gauguin.configuration.color_similarity_threshold;
        accum
      end.sort_by { |k, v| v }.first

      background_from_dominant && background_from_dominant[0]
    end
  end
end

