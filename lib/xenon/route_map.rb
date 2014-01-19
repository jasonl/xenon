module Xenon
  class RouteComponent
    attr_reader :components
    attr_accessor :endpoint

    def initialize
      @components = {}
      @endpoint = nil
    end
  end

  class RouteMap
    # Constants
    #-----------------------------------------------------------------------------
    VALID_METHODS = [:GET, :POST, :PATCH, :PUT, :DELETE]

    # Instance Methods
    #-----------------------------------------------------------------------------
    def initialize
      @routes = {}
      VALID_METHODS.each do |method|
        @routes[method] ||= RouteComponent.new
      end
    end

    def add_mapping(controller, action, method, path)
      validate_method(method)
      route = @routes[method]

      path_components = path.split("/").drop(1)

      path_components.each do |component|
        route.components[component] ||= RouteComponent.new
        route = route.components[component]
      end

      route.endpoint = controller + '#' + action
    end

    def resolve_path(path, method, params)
      route = @routes[method]
      path_components = path.split('/').drop(1) # Ignore the leading slash

      path_components.each do |component|
        if route.components[component]
          route = route.components[component]
        else
          slug, route = route.components.detect { |slug, route| slug[0] == ':' }
          return nil if route.nil?
          params[slug[1..-1].to_sym] = component
        end
      end

      return nil if route.endpoint.nil?
      return route.endpoint
    end

    private
    def validate_method(method)
      unless VALID_METHODS.include?(method)
      raise "InvalidMethod - only :GET, :POST, :PUT, :PATCH and :DELETE are supported"
      end
    end
  end
end
