module Gauguin
  class ColorsLimiter
    def call(colors)
      colors_limit = Gauguin.configuration.colors_limit

      return colors if colors.size < colors_limit
      colors.sort_by { |_, percentage| percentage }.reverse.take(colors_limit)
    end
  end
end
