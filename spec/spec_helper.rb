if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start
end

require 'bundler/setup'
require './lib/gauguin'
require 'pry'

Bundler.setup

RSpec.configure do |config|
end

def configure(config_option, value)
  old_value = Gauguin.configuration.send(config_option)

  before do
    Gauguin.configuration.send("#{config_option}=", value)
  end

  after do
    Gauguin.configuration.send("#{config_option}=", old_value)
  end
end

class FakeImage
  attr_accessor :magic_black_pixel, :magic_red_pixel,
    :magic_white_pixel, :magic_red_little_transparent_pixel,
    :pixels_repository, :color_histogram, :rows, :columns,
    :pixels, :colors_to_pixels
end

