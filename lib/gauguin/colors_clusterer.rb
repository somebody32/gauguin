module Gauguin
  class ColorsClusterer
    def call(colors)
      clusters = {}
      while !colors.empty?
        pivot = colors.shift
        group = [pivot]

        colors, pivot, group = find_all_similar(colors, pivot, group)

        clusters[pivot] = group
      end

      update_pivots_percentages(clusters)

      clusters
    end

    def clusters(colors)
      clusters = self.call(colors)
      clusters.keys.sort_by { |c| c[1] }.last(Gauguin.configuration.max_colors_count).reverse
    end

    def reversed_clusters(clusters)
      reversed_clusters = {}

      clusters.each do |pivot, group|
        group.each do |color|
          reversed_clusters[color] = pivot
        end
      end

      reversed_clusters
    end

    def above_threshold(colors, threshold)
      colors.select { |_, percentage| percentage > threshold }.size
    end

    private

    def find_all_similar(colors, pivot, group)
      loop do
        similar_colors, others = colors.partition { |c| c[0].similar?(pivot[0]) }
        break if similar_colors.empty?

        group += similar_colors
        colors = others

        pivot = group.sort_by { |e| e[1] }.last
      end

      [colors, pivot, group]
    end

    def update_pivots_percentages(clusters)
      clusters.each do |main_color, group|
        percentage = group.inject(0) { |sum, color| sum + color[1] }
        main_color[1] = percentage
      end
    end
  end
end
