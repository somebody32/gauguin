module Gauguin
  class Color
    attr_accessor :red, :green, :blue, :transparent

    def initialize(red, green, blue, transparent = false)
      self.red = red
      self.green = green
      self.blue = blue
      self.transparent = transparent
    end

    def ==(other)
      self.class == other.class && self.to_key == other.to_key
    end

    alias eql? ==

    def hash
      self.to_key.hash
    end

    def similar?(other_color)
      return false if transparent != other_color.transparent

      distance(other_color) < Gauguin.configuration.color_similarity_threshold
    end

    def distance(other_color)
      method = Gauguin.configuration.color_similarity_method
      return distance_lab(other_color) if method == :lab

      distance_cie94(other_color)
    end

    def distance_lab(other_color)
      (to_lab - other_color.to_lab).r
    end

    def distance_cie94(other_color, weighting_type = :graphic_arts)
      case weighting_type
      when :graphic_arts
        k_1 = 0.045
        k_2 = 0.015
        k_L = 1
      when :textiles
        k_1 = 0.048
        k_2 = 0.014
        k_L = 2
      else
        raise ArgumentError, "Unsupported weighting type #{weighting_type}."
      end

      k_C = k_H = 1

      l_1, a_1, b_1 = to_lab.to_a
      l_2, a_2, b_2 = other_color.to_lab.to_a

      delta_a = a_1 - a_2
      delta_b = b_1 - b_2

      c_1 = Math.sqrt((a_1 ** 2) + (b_1 ** 2))
      c_2 = Math.sqrt((a_2 ** 2) + (b_2 ** 2))

      delta_L = l_1 - l_2
      delta_C = c_1 - c_2

      delta_H2 = (delta_a ** 2) + (delta_b ** 2) - (delta_C ** 2)

      s_L = 1
      s_C = 1 + k_1 * c_1
      s_H = 1 + k_2 * c_1

      composite_L = (delta_L / (k_L * s_L)) ** 2
      composite_C = (delta_C / (k_C * s_C)) ** 2
      composite_H = delta_H2 / ((k_H * s_H) ** 2)
      Math.sqrt(composite_L + composite_C + composite_H)
    end

    def to_lab
      @lab ||= begin
        rgb_vector = to_vector
        xyz_vector = rgb_vector.to_xyz
        xyz_vector.to_lab
      end
    end

    def to_vector
      ColorSpace::RgbVector[*to_rgb]
    end

    def to_rgb
      [red, green, blue]
    end

    def to_a
      to_rgb + [transparent]
    end

    def to_key
      to_a
    end

    def to_s
      "rgb(#{red}, #{green}, #{blue})"
    end

    def inspect
      to_s
    end

    def transparent?
      transparent
    end
  end
end

