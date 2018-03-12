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
        puts "Colors total: #{colors.size}"

        colors = @colors_limiter.call(colors)
        puts "Colors after limitation: #{colors.size}"

        colors_clusters = @colors_clusterer.clusters(colors)
        puts "Colors clusters: #{colors_clusters.size}"

        @noise_reducer.call(colors_clusters)
      end
    end
  end
end

