module Xenon
  module ResourcePatterns
    module HtmlResources
      def html_resources(name, &block)
        controller_name = name.capitalize + "Controller"
        klass = get_or_create_controller(controller_name)

        unless klass.method_defined?(:index)
          klass.class_eval(index_method_body(name))
        end

        unless klass.method_defined?(:create)
          klass.class_eval(create_method_body(name))
        end

        unless klass.method_defined?(:show)
          klass.class_eval(show_method_body(name))
        end

        routes.add_mapping(name, :GET, controller_name, "show")
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

      def show_method_body(name)
        <<-SHOW_BODY
def show
  #{name.downcase.chomp('s')} = #{name.capitalize.chomp('s')}.find(1)
  @response.body << <<-BODY
    <html>
      <body>
        <strong>Title</strong>\#{#{name.downcase.chomp('s')}.title}
      </body>
    </html>
  BODY
end
SHOW_BODY
      end
    end
  end
end
