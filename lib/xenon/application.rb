class Application
  extend ResourcePatterns::HtmlResources
  @routes = {}

  def self.routes
    @routes
  end

  def routes
    self.class.routes
  end

  def call(env)
    request = Rack::Request.new(env)
    path_components = request.path.split('/')
    method = request.request_method.to_sym
    if routes[method]
      if routes[method][path_components[1]]
        controller_name, action_name = routes[method][path_components[1]].split('#')
        controller_klass = Object.const_get(controller_name)
        controller = controller_klass.new(request)
        if controller.respond_to?(action_name.to_sym)
          puts "Running #{controller_name}\"#{action_name}"
          controller.send(action_name.to_sym)
          return controller.response
        else
          return [404, {'Content-Type' => 'text/html'}, ["Action #{action_name} not found"]]
        end
      else
        return [404, {'Content-Type' => 'text/html'}, ["Not found"]]
      end
    end
    return [404, {'Content-Type' => 'text/html'}, ["Method not found"]]
  end

  def self.define(&block)
    instance_eval(&block)
    puts routes.inspect
  end
end
