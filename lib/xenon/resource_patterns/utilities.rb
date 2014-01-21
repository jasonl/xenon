module Xenon
  module ResourcePatterns
    module Utilities
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
end
