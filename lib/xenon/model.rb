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
    end

    attr_reader :attributes

    def self.inherited(subclass)
      Schema.add_model(subclass)
    end

    def self.attribute_names
      @columns.keys
    end

    def initialize(values = {})
      self.class.validate_attributes_hash!(values)

      @attributes = {}
      _columns.each do |name, column|
        @attributes[name.to_sym] = Attribute.new(column, values[name])
      end
    end

    def self.table_name
      @table_name ||= "#{self.name.downcase}s"
    end

    def self._primary_key
      @primary_key
    end

    # Determines if the table backing this model actually exists in the DB.
    #
    # @return [Boolean] true if the table exists
    def self.table_exists?
      result = Database.execute(table_exists_sql)
      result[0] && result[0]["count"].to_i > 0
    end

    # Returns information about the table as it exists in the DB.
    #
    # @return [Xenon::Column] with details of the columns. No guarantees as to column order.
    def self.table_information
      result = Database.execute(table_information_sql)
      result.map { |tuple| Column.initialize_from_db_tuple(tuple) }
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

    # Generates the SQL to test for the existence of a table. This may need to be checked
    # that it is confined to the particular database, rather than the public schema.
    def self.table_exists_sql
      sql = "SELECT COUNT(*) FROM pg_class WHERE relname='#{table_name}' AND relkind='r'"
    end

    # Generates the SQL to return the column information for the table. Again, this is
    # not scoped to a particular schema.
    def self.table_information_sql
      <<-SQL
      SELECT
              a.attname AS name,
              CASE 
                  WHEN atttypmod = -1 THEN null       
                  ELSE (atttypmod - 4) & 65535            -- calculate the scale  
              END AS size,
              t.typname AS type,
              CASE WHEN a.attnotnull = 't' THEN 't' ELSE 'f' END AS not_null,
              CASE WHEN r.contype = 'p' THEN 't' ELSE 'f' END AS primary_key
      FROM
              pg_class c 
              JOIN pg_attribute a ON a.attrelid = c.oid
              JOIN pg_type t ON a.atttypid = t.oid
              LEFT JOIN pg_catalog.pg_constraint r ON c.oid = r.conrelid 
                      AND r.conname = a.attname
      WHERE
              c.relname = '#{table_name}'
              AND a.attnum > 0
      SQL
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
