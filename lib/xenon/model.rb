module Xenon
  class Model
    def self.inherited(subclass)
      Schema.add_model(subclass)
    end

    def self.attribute(name, *opts)
      puts "Adding attribute #{name}"
      @attributes ||= {}
      @attributes[name] = Attribute.new(name, *opts)
      @table_name = self.name
    end

    def self.table_name
      @table_name ||= self.name
    end

    def self.create_table!
      Database.connection.exec(create_table_sql)
    end

    private
    def self.create_table_sql
      sql = "DROP TABLE IF EXISTS #{table_name}; "
      sql += "CREATE TABLE #{table_name} "
      sql += "("
      sql += @attributes.map { |name, attr| attr.schema_sql_fragment }.join(",")
      sql += ");"
      sql
    end
  end
end
