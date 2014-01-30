require 'logger'

module Xenon
  class Application
    @routes = RouteMap.new

    def self.routes
      @routes
    end

    def routes
      self.class.routes
    end

    # Set the application's root directory
    def self.set_root(root)
      @root = root
    end

    def self.root
      @root
    end

    def self.logger
      @logger ||= Logger.new(STDOUT)
    end

    def call(env)
      request = Rack::Request.new(env)
      method = request.request_method.to_sym
      action = routes.resolve_path(request.path, method, request.params)

      if action.nil?
        return [404, {'Content-Type' => 'text/html'}, ["Route #{method} #{request.path} not found"]]
      end

      controller_name, action_name = action.split("#")
      controller_klass = Object.const_get(controller_name)
      controller = controller_klass.new(request)
      if controller.respond_to?(action_name.to_sym)
        Application.logger.info("#{method.to_s.upcase} #{controller_name}\##{action_name}")
        controller.send(action_name.to_sym)
        return controller.response
      else
        return [404, {'Content-Type' => 'text/html'}, ["Action #{action_name} not found"]]
      end
    end

    def self.html_resource(name)
      ResourcePatterns::HtmlResource.new(name, routes)
    end

    def self.html_resources(name)
      ResourcePatterns::HtmlResources.new(name, routes)
    end

    def self.define(&block)
      instance_eval(&block)
    end
  end
end
