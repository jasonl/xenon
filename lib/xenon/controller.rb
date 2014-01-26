module Xenon
  class Controller
    attr_reader :response

    def initialize(request)
      @request = request
      @response = Rack::Response.new
      @response['Content-Type'] = "text/html"
    end

    def params
      @symbolized_params ||= symbolize_hash(@request.params)
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
    
    private
    def symbolize_hash(hash)
      result = {}
      hash.each do |key, value|
        result[key.to_sym] = value.is_a?(Hash) ? symbolize_hash(value) : value
      end
      result
    end
  end
end
