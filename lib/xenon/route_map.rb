class RouteMap
  def initialize
    @routes = {}
    @routes[:GET] ||= {}
    @routes[:POST] ||= {}
  end

  def add_mapping(path, method, controller, action)
    @routes[method][path] = controller + '#' + action
  end

  def resolve_path(path, method)
    path_components = path.split('/')

    if @routes[method]
      if @routes[method][path_components[1]]
        return @routes[method][path_components[1]].split('#')
      else
        raise "Route not found"
      end
    end
    raise "Method not found"
  end
end
