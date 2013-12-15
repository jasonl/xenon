module ResourcePatterns
  module HtmlResources
    def html_resources(name, &block)
      controller_name = name.upcase + "Controller"
      if Object.const_defined?(controller_name)
        klass = Object.const_get(controller_name)
      else
        new_anon_class = Class.new(Controller)
        klass = Object.const_set(controller_name, new_anon_class)
      end
      
      unless klass.method_defined?(:index)
        klass.class_eval(index_method_body(name))
      end
      
      @routes[:GET] ||= {}
      @routes[:POST] ||= {}
      @routes[:GET][name] ||= []
      @routes[:GET][name] = controller_name + '#' + "index"
    end
    
    private
    def index_method_body(name)
      "def index
       @response.body << \"#{name}\#index\"
     end"
    end
  end
end
