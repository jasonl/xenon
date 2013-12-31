module ResourcePatterns
  module HtmlResources
    def html_resources(name, &block)
      controller_name = name.capitalize + "Controller"
      if Object.const_defined?(controller_name)
        klass = Object.const_get(controller_name)
      else
        new_anon_class = Class.new(Controller)
        klass = Object.const_set(controller_name, new_anon_class)
      end

      unless klass.method_defined?(:index)
        klass.class_eval(index_method_body(name))
      end

      unless klass.method_defined?(:create)
        klass.class_eval(create_method_body(name))
      end

      routes.add_mapping(name, :GET, controller_name, "index")
      routes.add_mapping(name, :POST, controller_name, "create")
    end

    private
    def index_method_body(name)
      <<-INDEX_BODY
def index
  @response.body << "<html>
    <body>
       <h1>New #{name}</h1>
       <form method=\\"POST\\" action=\\"/#{name}\\">
         <input type=\\"submit\\" value=\\"Save\\" />
       </form>
    </body>
  </html>"
end
INDEX_BODY
    end

    def create_method_body(name)
      <<-CREATE_BODY
def create
  #{name.capitalize.chomp('s')}.create(:title => "test")
  @response.body << "<html>Success!</html>"
end
CREATE_BODY
    end
  end
end
