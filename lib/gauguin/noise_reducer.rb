module Gauguin
  class NoiseReducer
    def call(colors_clusters)
      pivots = []

      percentage_sum = 0
      colors_clusters.each_with_index do |color, i|
        min_diff = colors_clusters.map { |c| c[0].distance(color[0]) }.sort[1]
        puts [i+1, color[1], min_diff, percentage_sum].inspect if Gauguin.configuration.debug

        next if color_sum_is_full?(percentage_sum, min_diff)
        next if percentage_below_threshold?(color[1])

        pivots << color[0]
        percentage_sum += color[1]
      end

      reduced_clusters(colors_clusters, pivots)
    end

    private

    def percentage_below_threshold?(percentage)
      percentage < Gauguin.configuration.min_color_percentage
    end

    def color_sum_is_full?(percentage, min_diff)
      percentage > Gauguin.configuration.min_percentage_sum &&
        min_diff < Gauguin.configuration.sum_exception_threshold
    end

    def reduced_clusters(colors_clusters, pivots)
      colors_clusters.each_with_object({}) do |c, memo|
        memo[c[0]] = c[1] if pivots.include?(c[0])
      end
    end
  end
end
