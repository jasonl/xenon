module Xenon
  module ResourcePatterns
    class HtmlResource < Xenon::ResourcePattern

      def build_resource(route_map)
        klass = get_or_create_controller(controller_name)

        define_method_unless_defined(klass, :show, show_method_body(name))
        Resolver.register_implicit_template("#{name}/show", show_template(name))
        route_map.add_mapping(controller_name, 'show', :GET, "/#{name}")

        define_method_unless_defined(klass, :new, new_method_body(name))
        Resolver.register_implicit_template("#{name}/new", new_template(name))
        route_map.add_mapping(controller_name, 'new', :GET, "/#{name}/new")

        define_method_unless_defined(klass, :create, create_method_body(name))
        route_map.add_mapping(controller_name, 'create', :POST, "/#{name}")

        define_method_unless_defined(klass, :edit, edit_method_body(name))
        Resolver.register_implicit_template("#{name}/edit", edit_template(name))
        route_map.add_mapping(controller_name, 'edit', :GET, "/#{name}/edit")

        define_method_unless_defined(klass, :update, update_method_body(name))
        route_map.add_mapping(controller_name, 'update', :PATCH, "/#{name}")

        define_method_unless_defined(klass, :destroy, destroy_method_body(name))
        route_map.add_mapping(controller_name, "destroy", :DELETE, "/#{name}")
      end

      private

      # GET /resource/:id
      #--------------------------------------------------------------------------

      def show_method_body(name)
        <<-SHOW_BODY
def show
  @#{name} = #{model_name}.read(params[:id]) || Post.new
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
    %form(action=\"/#{name}\" method=\"POST\")\n"
        model_class.attribute_names.each do |attribute_name|
          html <<
"      .control-group
        %label #{attribute_name}
        %input(type=\"text\" name=\"#{name}[#{attribute_name}]\")\n"
        end
        html <<
"        %input(type=\"submit\" value=\"Save\")\n"
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
  @#{name} = #{model_name}.read(1)
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
  @#{name} = #{model_name}.update(1, params[:#{name}])
end
UPDATE_BODY
      end

      # DELETE /resource/:id
      #--------------------------------------------------------------------------
      def destroy_method_body(name)
        <<-DESTROY_BODY
def destroy
  #{model_name}.delete(1)
end
DESTROY_BODY
      end
    end
  end
end
