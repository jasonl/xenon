module Xenon
  class Controller
    attr_reader :response

    def initialize(request)
      @request = request
      @response = Rack::Response.new
      @response['Content-Type'] = "text/html"
    end

    def params
      @request.params
    end

    def render(template_name)
      template = Resolver.resolve_template(template_name)
      if template
        engine = Haml::Engine.new(template)
        @response.body << engine.render(self)
      else
        raise "Template Not Found!"
      end
    end
  end
end
