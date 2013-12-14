class Application
  def call(env)
    return [200, {"Content-Type" => "text/html"}, "This is a test"]
  end
end
