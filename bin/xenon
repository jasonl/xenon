#! /usr/bin/env ruby

require 'rack'
require 'xenon'

app = Rack::Builder.new do 
  run XenonApplication.new
end

Rack::Handler::Webrick.run app, :Port => 5678
