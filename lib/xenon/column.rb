module Xenon
  class Column
    attr_reader :name, :primary_key, :type

    TYPES = [:string, :text, :integer, :foreign_key]

    def initialize(name, *options)
      @options = options.extract_options!.dup
      sanitize_options!(@options)
      @primary_key = @options.delete(:primary_key) || false
      @type = @options[:type]
      @name = name.to_s
      @opts = options.dup
    end

    # Compares if a column is equivalent to another one.
    #
    # @return Boolean
    def ==(other_column)
      return false unless other_column.is_a?(Column)
      @name == other_column.name && @primary_key == other_column.primary_key && @type == other_column.type
    end

    # Initializes a column object from the info returned by the DB.
    #
    # @return Xenon::Column
    def self.initialize_from_db_tuple(tuple)
      table_information = {}
      table_information[:type] = db_type_to_type(tuple["type"])
      table_information[:primary_key] = tuple["primary_key"] == 't'
      return Column.new(tuple["name"], table_information)
    end

    def cast_to_type(val)
      case type
      when :integer
        val.to_i
      when :string, :text
        val
      else
        raise "Unknown type"
      end
    end

    def schema_sql_fragment
      sql = "#{@name} #{sql_type}"
      sql += " " + sql_constraint unless sql_constraint.length == 0
      sql
    end

    private
    def sanitize_options!(options)
      if options[:type].nil?
        raise ArgumentError.new("No :type option specified for attribute")
      end

      unless TYPES.include?(options[:type])
        raise ArgumentError.new("Invalid :type option specified")
      end
    end

    def sql_type
      case @type
      when :string then "VARCHAR(255)"
      when :text then "TEXT"
      when :integer then "INTEGER"
      when :foreign_key then "INTEGER" #TODO: this should pick type
      end
    end

    def self.db_type_to_type(_type)
      case _type
      when "varchar" then :string
      when "text" then :text
      when "int4" then :integer
      end
    end

    def sql_constraint
      sql_constraints = []
      if @options[:required] == true
        sql_constraints << "NOT NULL"
      end

      if @type == :foreign_key
        # sql_constraints << "REFERENCES #{other_table}(#{other_key})"
      end

      if @primary_key
        sql_constraints << "PRIMARY KEY"
      end
      sql_constraints.join(" ")
    end
  end
end
