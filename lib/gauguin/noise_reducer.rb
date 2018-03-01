module Gauguin
  class NoiseReducer
    def call(colors_clusters)
      pivots = []

      percentage_sum = 0
      colors_clusters.each do |color|
        pivots << color[0]
        percentage_sum += color[1]
        break if percentage_sum > Gauguin.configuration.min_percentage_sum
      end

      reduced_clusters(colors_clusters, pivots)
    end

    private

    def reduced_clusters(colors_clusters, pivots)
      colors_clusters.reduce({}) do |memo, c|
        memo[c[0]] = c[1] if !c[0].transparent? && pivots.include?(c[0])
        memo
      end
    end
  end
end
