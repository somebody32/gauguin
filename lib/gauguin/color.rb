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

      distance(other_color) <= Gauguin.configuration.color_similarity_threshold
    end

    def distance(other_color, color_similarity_method: nil)
      color_similarity_method ||= Gauguin.configuration.color_similarity_method
      case color_similarity_method
      when :lab
        distance_lab(other_color)
      when :cie94_graphics
        distance_cie94(other_color, :graphic_arts)
      when :cie94_textile
        distance_cie94(other_color, :textiles)
      when :e2k
        distance_e2k(other_color)
      else
        raise "Unsupported color distance algorithm!"
      end
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

    def distance_e2k(other_color)
      # Weighting factors
      kl = 1.0
      kc = 1.0
      kh = 1.0

      # Conversions
      radians = lambda { |n| n * (Math::PI / 180.0) }
      degrees = lambda { |n| n * (180.0 / Math::PI) }

      l_1, a_1, b_1 = to_lab.to_a
      l_2, a_2, b_2 = other_color.to_lab.to_a

      # Step 1. Calculate c1, c2, c_bar, c1_prime, c2_prime, h_prime
      c1 = Math.sqrt( (a_1 ** 2) + (b_1 ** 2) ) # 2
      c2 = Math.sqrt( (a_2 ** 2) + (b_2 ** 2) ) # 2
      c_bar = (c1 + c2).to_f / 2 # 3

      g = 0.5 * ( 1 - Math.sqrt( (c_bar ** 7).to_f / (c_bar ** 7 + 25 ** 7) ) ) # 4

      a1_prime = (1 + g) * a_1 # 5
      a2_prime = (1 + g) * a_2 # 5

      c1_prime = Math.sqrt( (a1_prime ** 2) + (b_1 ** 2) ) # 6
      c2_prime = Math.sqrt( (a2_prime ** 2) + (b_2 ** 2) ) # 6

      h1 = degrees.call( Math.atan2(b_1, a1_prime) ) # 7
      h2 = degrees.call( Math.atan2(b_2, a2_prime) ) # 7
      h1 = h1 + 360 if h1 < 0 # 7
      h2 = h2 + 360 if h2 < 0 # 7

      # Step 2. Calculate delta_l, delta_c, h_bar, delta_h
      delta_l = l_2 - l_1 # 8
      delta_c = c2_prime - c1_prime # 9

      # h_prime: 10
      h_diff = h1 - h2
      if c1_prime * c2_prime == 0
        h_prime = 0
      elsif h_diff.abs <= 180
        h_prime = h2 - h1
      elsif h_diff > 180
        h_prime = (h2 - h1) - 360
      else
        h_prime = (h1 - h2) + 360
      end

      delta_h = 2 * Math.sqrt(c1_prime * c2_prime) * Math.sin(radians.call(h_prime.to_f / 2)) # 11

      # Step 3. Calculate l_bar, c_bar, h_bar, t, delta_theta, rc, sl, sh, sc, rt
      l_bar = (l_1 + l_2).to_f / 2 # 12
      c_bar = (c1_prime + c2_prime).to_f / 2 # 13

      # h_bar: 14
      if c1_prime * c2_prime == 0
        h_bar = h1 + h2
      elsif h_diff.abs <= 180
        h_bar = (h1 + h2).to_f / 2
      elsif h1 + h2 < 360
        h_bar = (h1 + h2 + 360).to_f / 2
      elsif h1 + h2 >= 360
        h_bar = (h1 + h2 - 360).to_f / 2
      end

      # t: 15
      t = 1 -
          (0.17 * Math.cos(radians.call(h_bar - 30))) +
          (0.24 * Math.cos(radians.call(2 * h_bar))) +
          (0.32 * Math.cos(radians.call(3 * h_bar + 6))) -
          (0.20 * Math.cos(radians.call(4 * h_bar - 63)))

      delta_theta = 30 * Math.exp( -(( (h_bar - 275) / 25 ) ** 2) ) # 16
      rc = 2 * Math.sqrt( (c_bar ** 7).to_f / (c_bar ** 7 + 25 ** 7) ) # 17

      # sl: 18
      sl = 1 + ( ( 0.015 * ((l_bar - 50) ** 2) ).to_f /
                 ( Math.sqrt(20 + ( (l_bar - 50) ** 2 ) ) ) )

      sc = 1 + 0.045 * c_bar # 19
      sh = 1 + 0.015 * c_bar * t # 20
      rt = -(Math.sin(radians.call(2 * delta_theta)) * rc) # 21

      # Calculate the CIEDE2000 Color-Difference
      Math.sqrt(
        ( ( delta_l.to_f / (kl * sl) ) ** 2) +
        ( ( delta_c.to_f / (kc * sc) ) ** 2 ) +
        ( ( delta_h.to_f / (kh * sh) ) ** 2 ) +
        ( rt * ( (delta_c.to_f / (kc * sc)) * (delta_h.to_f / (kh * sh)) ) )
      )
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
      @as_array ||= (to_rgb + [transparent])
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
