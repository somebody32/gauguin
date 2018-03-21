#!/usr/bin/ruby

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gauguin'

Gauguin.configure do |c|
  c.color_similarity_threshold = 5
  c.max_colors_count = 15
  c.colors_limit = 2000
  c.color_similarity_method = :e2k
  c.debug = true
end

IMAGES = {
  google_logo: ['./test_images/logo.png', 4],
  nasa_logo: ['./test_images/nasa_logo.png', 3],
  nbc_logo: ['./test_images/nbc_logo.png', 14],
  firefox_logo: ['./test_images/firefox_logo.png', 14],
  photo: ['./test_images/photo.jpg', '> 15'],
  test_image: ['./test_images/test.jpg', 5],
  tb_logo: ['./test_images/tb_logo.jpg', 5]
}

IMAGES.each do |name, data|
  path, expected = data
  puts "Processing #{name}"
  puts "Detected Colors: #{Gauguin::Painting.new(path).palette.size}, Expected: #{expected}"
  puts "="*80
end