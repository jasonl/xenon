module Xenon
  class Model
    module CrudClassMethods
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Creates a new model with the supplied attributes, and returns an
        # instance of it.
        def create(attrs)
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

        # Reads the database row identified by the primary key, and
        # instantiates a model.
        def read(id)
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

        # Deletes the database row identified by id.
        def self.delete(id)
          sql = "DELETE FROM #{table_name} WHERE "
          sql += Database.connection.escape_identifier(@primary_key.name)
          sql += " = "
          sql += Database.connection.escape_string(id.to_s)

          Database.connection.async_exec(sql)
        end
      end
    end
  end
end
