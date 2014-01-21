module Xenon
  module ResourcePatterns
    module HtmlResource
      def html_resource(name)
        controller_name = name.capitalize + "Controller"
        klass = get_or_create_controller(controller_name)

        define_method_unless_defined(klass, :show, show_method_body(name))
        Resolver.register_implicit_template("#{name}/show", show_template(name))
        routes.add_mapping(controller_name, 'show', :GET, "/#{name}")

        define_method_unless_defined(klass, :new, new_method_body(name))
        Resolver.register_implicit_template("#{name}/new", new_template(name))
        routes.add_mapping(controller_name, 'new', :GET, "/#{name}/new")

        define_method_unless_defined(klass, :create, create_method_body(name))
        routes.add_mapping(controller_name, 'create', :POST, "/#{name}")

        define_method_unless_defined(klass, :edit, edit_method_body(name))
        Resolver.register_implicit_template("#{name}/edit", edit_template(name))
        routes.add_mapping(controller_name, 'edit', :GET, "/#{name}/edit")

        define_method_unless_defined(klass, :update, update_method_body(name))
        routes.add_mapping(controller_name, 'update', :PATCH, "/#{name}")

        define_method_unless_defined(klass, :destroy, destroy_method_body(name))
        routes.add_mapping(controller_name, "destroy", :DELETE, "/#{name}")
      end

      def model_class
        Post
      end

      def model_name
        "Post"
      end

      # GET /resource/:id
      #--------------------------------------------------------------------------

      def show_method_body(name)
        <<-SHOW_BODY
def show
  @#{name} = #{model_name}.read(params[:id])
  render "#{name}/show"
end
SHOW_BODY
      end

      def show_template(name)
        html = []
        html <<
"%html
  %head
    %title Test
  %body
    %dl\n"
        model_class.attribute_names.each do |attribute_name|
          html <<
"      %dt #{attribute_name}
       %dd= @#{name}.#{attribute_name}\n"
        end
        html.join
      end

      # GET /resource/new
      #--------------------------------------------------------------------------
      def new_method_body(name)
        <<-NEW_BODY
def new
  @#{name} = #{model_name}.new
  render "#{name}/new"
end
NEW_BODY
      end

      def new_template(name)
        html = []
        html <<
"%html
  %head
    %title Test
  %body
    %form(action=\"/#{name}\" method=\"POST\")"
        model_class.attribute_names.each do |attribute_name|
          html <<
"     .control-group
        %label #{attribute_name}
        %input(type=\"text\" name=\"#{name}[#{attribute_name}]\")"
        end
        html <<
"       %input(type=\"submit\" value=\"Save\")"
        html.join
      end

      # POST /resource
      #-------------------------------------------------------------------------

      def create_method_body(name)
        <<-CREATE_BODY
def create
  @#{name} = #{model_name}.create(params["#{name}"])
end
CREATE_BODY
      end

      # GET /resource/edit
      #--------------------------------------------------------------------------

      def edit_method_body(name)
        <<-EDIT_BODY
def edit
  @#{name} = #{model_name}.read(params[:id])
  render "#{name}/edit"
end
EDIT_BODY
      end

      def edit_template(name)
        html = []
        html <<
"%html
  %head
    %title Test
  %body
    %form(action=\"/#{name}\" method=\"POST\")\n"
        model_class.attribute_names.each do |attribute_name|
          html <<
"      .control-group
        %label #{attribute_name}
        %input(type=\"text\" name=\"#{name}[#{attribute_name}]\" value=\"\#{@#{name}.#{attribute_name}}\")\n"
        end
        html <<
"      %input(type=\"submit\" value=\"Save\")\n"
        html.join
      end

      # PATCH /resource/:id
      #--------------------------------------------------------------------------
      def update_method_body(name)
        <<-UPDATE_BODY
def update
  @#{name} = #{model_name}.update(params[:id], params[:#{name}])
end
UPDATE_BODY
      end

      # DELETE /resource/:id
      #--------------------------------------------------------------------------
      def destroy_method_body(name)
        <<-DESTROY_BODY
def destroy
  #{model_name}.delete(params[:id])
end
DESTROY_BODY
      end
    end
  end
end
