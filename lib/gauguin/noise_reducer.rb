module Gauguin
  class NoiseReducer
    def call(colors_clusters)
      pivots = []

      percentage_sum = 0
      colors_clusters.each do |color|
        next if color[1] < Gauguin.configuration.min_color_percentage

        pivots << color[0]
        percentage_sum += color[1]
        break if percentage_sum > Gauguin.configuration.min_percentage_sum
      end

      reduced_clusters(colors_clusters, pivots)
    end

    private

    def reduced_clusters(colors_clusters, pivots)
      colors_clusters.each_with_object({}) do |c, memo|
        memo[c[0]] = c[1] if !c[0].transparent? && pivots.include?(c[0])
      end
    end
  end
end
