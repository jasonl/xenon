require_relative 'model/crud_class_methods'
require_relative 'model/crud_instance_methods'
require_relative 'model/attributes'

module Xenon
  class Model
    include CrudInstanceMethods
    include CrudClassMethods
    include Attributes

    class << self
      attr_reader :columns
      attr_reader :_primary_key
    end

    def self.inherited(subclass)
      Schema.add_model(subclass)
    end

    def initialize(values = {})
      self.class.validate_attributes_hash!(values)

      @attributes = {}
      _columns.each do |name, column|
        @attributes[name.to_sym] = Attribute.new(column, values[name])
      end
    end

    def self.table_name
      @table_name ||= self.name
    end

    def self.create_table!
      Database.execute(create_table_sql)
    end

    private
    def self.validate_attributes_hash!(values)
      error_keys = values.inject([]) do |errors, (name, value)|
        errors << name unless @columns[name]
        errors
      end

      if error_keys.length > 0
        raise "Invalid attributes: #{error_keys.join(",")}"
      end
    end

    def self.create_table_sql
      raise "Primary key not defined for #{self.class.name}" if @primary_key.nil?
      sql = "DROP TABLE IF EXISTS #{table_name}; "
      sql += "CREATE TABLE #{table_name} "
      sql += "("
      sql += @columns.map { |name, attr| attr.schema_sql_fragment }.join(", ")
      sql += ");"
      sql
    end

    # Instance methods
    #-----------------------------------------------------------------------------

    # These are prefixed with an underscore to minimise the pollution of the
    # namespace, and leave it available for attribute method definitions.

    def _table_name
      self.class.table_name
    end

    def _primary_key
      self.class._primary_key
    end

    def _columns
      self.class.columns
    end
  end
end
