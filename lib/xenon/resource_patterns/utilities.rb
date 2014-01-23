module Xenon
  class ResourcePattern
    attr_reader :name

    def initialize(name, route_map)
      @name = name
      build_resource(route_map)
    end

    def build_resource(route_map)
      raise "Not implemented!"
    end

    def model_class
      Object.const_get(model_name)
    end

    def model_name
      @name.capitalize.chomp('s')
    end

    def controller_name
      @name.capitalize + "Controller"
    end

    def get_or_create_controller(controller_name)
      if Object.const_defined?(controller_name)
        klass = Object.const_get(controller_name)
      else
        new_anon_class = Class.new(Controller)
        klass = Object.const_set(controller_name, new_anon_class)
      end
    end

    def define_method_unless_defined(klass, name, body)
      unless klass.method_defined?(name)
        klass.class_eval(body)
      end
    end
  end
end
