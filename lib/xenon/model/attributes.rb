module Xenon
  class Model
    module Attributes
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def attribute(name, opts = {})
          puts "Adding attribute #{name}"
          @columns ||= {}
          column = Column.new(name, opts)
          @columns[name] = column
          @table_name = self.name

          if opts[:primary_key] == true
            if @primary_key.nil?
              @primary_key = column
            else
              raise "Attempting to define both #{@primary_key.name} and #{column.name} as primary keys"
            end
          end

          define_method(name) do
            @attributes[:"#{name.to_s}"].get
          end

          define_method(name.to_s + "=") do |value|
            @attributes[:"#{name.to_s}"].set(value)
          end
        end

        def string(name, options = {})
          options = options.merge(:type => :string)
          attribute(name, options)
        end

        def integer(name, options = {})
          options = options.merge(:type => :integer)
          attribute(name, options)
        end

        def text(name, options = {})
          options = options.merge(:type => :text)
          attribute(name, options)
        end

        def primary_key(name, options = {})
          options = options.dup
          options[:type] ||= :integer
          options[:primary_key] = true
          attribute(name, options)
        end
      end
    end
  end
end
