Gem::Specification.new do |s|
  s.name         = "xenon"
  s.summary      = "A new framework"
  s.description  = "A new framework"
  s.version      = "0.0.1"
  s.authors      = ["Jason Langenauer"]
  s.email        = "jason@jasonlangenauer.com"
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = "lib"

  s.add_dependency "rack", "1.5.2"
  s.add_dependency "pg", "0.17.1"

  s.add_development_dependency "rspec", "3.0.0.beta1"

  s.executables << "xenon"
end
