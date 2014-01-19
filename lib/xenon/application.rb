module Xenon
  class Application
    extend ResourcePatterns::HtmlResources
    @routes = RouteMap.new

    def self.routes
      @routes
    end

    def routes
      self.class.routes
    end

    def call(env)
      request = Rack::Request.new(env)
      method = request.request_method.to_sym
      controller_name, action_name = routes.resolve_path(request.path, method, request.params)
      controller_klass = Object.const_get(controller_name)
      controller = controller_klass.new(request)
      if controller.respond_to?(action_name.to_sym)
        puts "Running #{controller_name}\"#{action_name}"
        controller.send(action_name.to_sym)
        return controller.response
      else
      return [404, {'Content-Type' => 'text/html'}, ["Action #{action_name} not found"]]
      end
    end

    def self.define(&block)
      instance_eval(&block)
      puts routes.inspect
    end
  end
end
