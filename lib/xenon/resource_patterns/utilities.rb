module Xenon
  class ResourcePattern
    attr_reader :name, :routes

    def initialize(name, routes)
      @name = name
      @routes = routes
      build_resource
    end

    def build_resource
      raise "Not implemented!"
    end

    private

    def resource
      @name.chomp('s')
    end

    def resources
      @name.chomp('s') + "s"
    end

    def model_class
      Object.const_get(model_class_name)
    end

    def model_class_name
      @name.capitalize.chomp('s')
    end

    def model_attributes(&block)
      model_class.columns.each(&block)
    end

    def controller_name
      model_class_name + "Controller"
    end

    def resolver
      Resolver
    end

    def render_internal_template(file_name)
      template = File.read(File.join(Xenon.gem_root, "xenon", "templates", resource_pattern, file_name))
      r = ERB.new(template, nil, "-").result(binding)
      puts r
      r
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
