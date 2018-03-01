module Gauguin
  class Painting
    def initialize(path)
      @image ||= Gauguin::Image.new(path)
      @colors_retriever = Gauguin::ColorsRetriever.new(@image)
      @colors_limiter = Gauguin::ColorsLimiter.new
      @noise_reducer = Gauguin::NoiseReducer.new
      @colors_clusterer = Gauguin::ColorsClusterer.new
    end

    def palette
      @palette ||= begin
        colors = @colors_retriever.colors
        colors = @colors_limiter.call(colors)
        colors_clusters = @colors_clusterer.clusters(colors)
        @noise_reducer.call(colors_clusters)
      end
    end
  end
end

