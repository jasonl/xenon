module Xenon
  module ResourcePatterns
    class HtmlResource < Xenon::ResourcePattern
      def resource_definition
        {
          show:    {path:"/#{name}",      method: :GET,    template:"show.haml.erb"},
          new:     {path:"/#{name}/new",  method: :GET,    template: "new.haml.erb"},
          create:  {path:"/#{name}",      method: :POST,   templatte: nil},
          edit:    {path:"/#{name}/edit", method: :GET,    template: "edit.haml.erb"},
          update:  {path:"/#{name}",      method: :PATCH,  template: nil},
          destroy: {path:"/#{name}",      method: :DELETE, template: nil},
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
        "html_resource"
      end

      # GET /resource/:id
      #--------------------------------------------------------------------------
      def show_method_body
        <<-SHOW_BODY
          def show
            @#{resource} = #{model_class_name}.read(1)
            render "#{name}/show"
          end
        SHOW_BODY
      end

      # GET /resource/new
      #--------------------------------------------------------------------------
      def new_method_body
        <<-NEW_BODY
          def new
            @#{resource} = #{model_class_name}.new
            render "#{name}/new"
          end
        NEW_BODY
      end

      # POST /resource
      #-------------------------------------------------------------------------
      def create_method_body
        <<-CREATE_BODY
          def create
            @#{resource} = #{model_class_name}.create(params[:#{resource}])
          end
        CREATE_BODY
      end

      # GET /resource/edit
      #--------------------------------------------------------------------------
      def edit_method_body
        <<-EDIT_BODY
          def edit
            @#{resource} = #{model_class_name}.read(1)
            render "#{name}/edit"
          end
        EDIT_BODY
      end

      # PATCH /resource
      #--------------------------------------------------------------------------
      def update_method_body
        <<-UPDATE_BODY
          def update
            @#{resource} = #{model_class_name}.update(1, params[:#{resource}])
          end
        UPDATE_BODY
      end

      # DELETE /resource
      #--------------------------------------------------------------------------
      def destroy_method_body
        <<-DESTROY_BODY
          def destroy
            #{model_class_name}.delete(1)
          end
        DESTROY_BODY
      end
    end
  end
end
