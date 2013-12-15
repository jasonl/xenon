class Controller
  attr_reader :response

  def initialize(request)
    @request = request
    @response = Rack::Response.new
    @response['Content-Type'] = "text/html"
  end
end
