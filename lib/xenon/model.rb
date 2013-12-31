module Xenon
  class Model
    def self.inherited(subclass)
      Schema.add_model(subclass)
    end

    def initialize(values)
      self.class.validate_attributes_hash!(values)
      @columns.each do |name, column|
        @attributes[name] = Attribute.new(column, values[name])
      end
    end

    def self.attribute(name, *opts)
      puts "Adding attribute #{name}"
      @columns ||= {}
      @columns[name] = Column.new(name, *opts)
      @table_name = self.name
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
      sql = "DROP TABLE IF EXISTS #{table_name}; "
      sql += "CREATE TABLE #{table_name} "
      sql += "("
      sql += @columns.map { |name, attr| attr.schema_sql_fragment }.join(",")
      sql += ");"
      sql
    end
  end
end
