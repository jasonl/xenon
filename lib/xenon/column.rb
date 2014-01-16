module Xenon
  class Column
    attr_reader :name

    TYPES = [:string, :text, :integer, :foreign_key]

    def initialize(name, *options)
      @options = options.extract_options!
      sanitize_options!
      @name = name.to_s
      @opts = options.dup
    end

    def type
      @options[:type]
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
    def sanitize_options!
      if @options[:type].nil?
        raise ArgumentError.new("No :type option specified for attribute")
      end

      unless TYPES.include?(@options[:type])
        raise ArgumentError.new("Invalid :type option specified")
      end
    end

    def sql_type
      case type
      when :string then "VARCHAR(255)"
      when :text then "TEXT"
      when :integer then "INTEGER"
      when :foreign_key then "INTEGER" #TODO: this should pick type
      end
    end

    def sql_constraint
      sql_constraints = []
      if @options[:required] == true
        sql_constraints << "NOT NULL"
      end

      if @options[:type] == :foreign_key
        # sql_constraints << "REFERENCES #{other_table}(#{other_key})"
      end

      if @options[:primary_key] == true
        sql_constraints << "PRIMARY KEY"
      end
      sql_constraints.join(" ")
    end
  end
end
