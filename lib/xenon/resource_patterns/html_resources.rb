require 'erb'

module Xenon
  module ResourcePatterns
    class HtmlResources < Xenon::ResourcePattern
      def resource_definition
        {
          index:   {path: "/#{name}",          method: :GET,    template: "index.haml.erb"},
          show:    {path: "/#{name}/:id",      method: :GET,    template: "show.haml.erb"},
          new:     {path: "/#{name}/new",      method: :GET,    template: "new.haml.erb"},
          create:  {path: "/#{name}",          method: :POST,   template: nil},
          edit:    {path: "/#{name}/:id/edit", method: :GET,    template: "edit.haml.erb"},
          update:  {path: "/#{name}/:id",      method: :PATCH,  template: nil},
          destroy: {path: "/#{name}/:id",      method: :DELETE, template: nil}
        }
      end

      def build_resource          
        klass = get_or_create_controller(controller_name)
        resource_definition.each do |action, definition|
          define_method_unless_defined(klass, resource, self.send("#{action}_method_body"))
          resolver.register_implicit_template("#{name}/#{action}", render_internal_template(definition[:template])) if definition[:template]
          routes.add_mapping(controller_name, action.to_s, definition[:method], definition[:path])
        end
      end

      private
      
      def resource_pattern
        "html_resources"
      end

      def index_method_body
        <<-INDEX_BODY
          def index
            @#{resources} = #{model_class_name}.all
            render "#{name}/index"
          end
        INDEX_BODY
      end

      def show_method_body
        <<-SHOW_BODY
          def show
            @#{resource} = #{model_class_name}.read(1)
            render "#{name}/show"
          end
        SHOW_BODY
      end

      def new_method_body
        <<-NEW_BODY
          def new
            @#{resource} = #{model_class_name}.new
            render "#{name}/new"
          end
        NEW_BODY
      end      

      def create_method_body
        <<-CREATE_BODY
          def create
            @#{resource} = #{model_class_name}.create(params[:#{resource}])
          end
        CREATE_BODY
      end

      
      def edit_method_body
        <<-EDIT_BODY
          def edit
            @#{resource} = #{model_class_name}.read(params[:id])
            render "#{name}/edit"
          end
        EDIT_BODY
      end
      
      def update_method_body
        <<-UPDATE_BODY
          def update
            @#{resource} = #{model_class_name}.update(params[:id], params[:#{resource}])
          end
        UPDATE_BODY
      end
      
      def destroy_method_body
        <<-DESTROY_BODY
        def destroy
          @#{resource} = #{model_class_name}.delete(params[:id])
        end
        DESTROY_BODY
      end
    end
  end
end
