module Xenon
  class Model
    class << self
      attr_reader :columns
      attr_reader :primary_key
    end

    def self.inherited(subclass)
      Schema.add_model(subclass)
    end

    def initialize(values)
      self.class.validate_attributes_hash!(values)

      @attributes = {}
      self.class.columns.each do |name, column|
        @attributes[name.to_sym] = Attribute.new(column, values[name])
      end
    end

    def self.attribute(name, opts = {})
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

    def self.table_name
      @table_name ||= self.name
    end

    def self.create_table!
      Database.connection.exec(create_table_sql)
    end

    def self.create(attrs)
      validate_attributes_hash!(attrs)
      sql = "INSERT INTO #{table_name} ("
      sql += @columns.map { |name, col|
        puts col.inspect
        Database.connection.escape_identifier(col.name)
      }.join(",")
      sql += ") VALUES ("
      sql += @columns.map { |name, col|
        "E'" + Database.connection.escape_string(attrs[col.name] || "") + "'"
      }.join(",")
      sql += ")"

      result = Database.connection.async_exec(sql)
    end

    def self.read(id)
      sql = "SELECT * FROM #{table_name} WHERE "
      sql += Database.connection.escape_identifier(@primary_key.name)
      sql += " = "
      sql += Database.connection.escape_string(id.to_s)
      sql += " LIMIT 1"

      result = Database.connection.async_exec(sql)

      if result.cmd_tuples == 0
        return nil
      else
        new_model = self.new({})
        puts result[0]
        result[0].each do |key, value|
          new_model.send(key + '=', value)
        end
        new_model
      end
    end

    def self.delete(id)
      sql = "DELETE FROM #{table_name} WHERE "
      sql += Database.connection.escape_identifier(@primary_key.name)
      sql += " = "
      sql += Database.connection.escape_string(id.to_s)

      Database.connection.async_exec(sql)
    end

    def delete
      sql = "DELETE FROM #{_table_name} WHERE "
      sql += Database.connection.escape_identifier(_primary_key.name)
      sql += " = "
      sql += Database.connection.escape_string(@attributes[_primary_key.name.to_sym].get)

      Database.connection.async_exec(sql)
    end

    private
    def self.validate_attributes_hash!(values)
      error_keys = values.inject([]) do |errors, (name, value)|
        errors << name unless @columns[name]
        errors
      end

      if error_keys.length > 0
        raise "Invalid attributes: #{errors.join(",")}"
      end
    end

    def self.create_table_sql
      raise "Primary key not defined for #{self.class.name}" if @primary_key.nil?
      sql = "DROP TABLE IF EXISTS #{table_name}; "
      sql += "CREATE TABLE #{table_name} "
      sql += "("
      sql += @columns.map { |name, attr| attr.schema_sql_fragment }.join(",")
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
      self.class.primary_key
    end
  end
end
