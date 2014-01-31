require 'rubygems'
require 'bundler/setup'
require 'xenon'

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = :documentation
end