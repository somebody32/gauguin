module Gauguin
  class Painting
    attr_reader :color_count

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

        colors_clusters = @colors_clusterer.clusters(colors)
        puts "Colors clusters: #{colors_clusters.size}" if debug_mode

        @noise_reducer.call(colors_clusters)
      end
    end
  end
end

