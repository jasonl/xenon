module Xenon
  class Resolver
    @templates = {}

    def self.register_implicit_template(name, template)
      @templates[name] = template
    end

    def self.resolve_template(name)
      template_file = File.join(Application.root, "views", name + ".haml")
      if File.exist?(template_file)
        File.read(template_file)
      else
        @templates[name]
      end
    end
  end
end
