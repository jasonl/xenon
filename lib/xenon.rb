require 'haml'
require 'xenon/utilities'

require 'xenon/schema'
require 'xenon/database'
require 'xenon/column'
require 'xenon/attribute'
require 'xenon/model'
require 'xenon/resolver'

require 'xenon/resource_patterns/utilities'
require 'xenon/resource_patterns/html_resources'
require 'xenon/resource_patterns/html_resource'
require 'xenon/route_map'
require 'xenon/application'
require 'xenon/controller'

module Xenon
  def self.gem_root
    @@gem_root
  end
   def self.gem_root=(gem_root)
     @@gem_root = gem_root
   end
end

Xenon.gem_root = File.dirname(__FILE__)