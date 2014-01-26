module Xenon
  class Model
    module CrudClassMethods
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def all
          return []
        end
      
        # Creates a new model with the supplied attributes, and returns an
        # instance of it.
        def create(values)
          a = new(values)
          a.insert
          a
        end

        # Reads the database row identified by the primary key, and
        # instantiates a model.
        def read(id)
          sql = "SELECT * FROM #{table_name} WHERE "
          sql += Database.quote_identifier(@primary_key.name)
          sql += " = "
          sql += Database.quote_value(id, @primary_key.type)
          sql += " LIMIT 1"

          result = Database.execute(sql)

          if result.cmd_tuples == 0
            return nil
          else
            new_model = self.new({})
            result[0].each do |key, value|
              new_model.send(key + '=', value, true)
            end
            new_model
          end
        end

        def update(id, values)
          model = read(id)
          model.update(values)
          model
        end

        # Deletes the database row identified by id.
        def self.delete(id)
          sql = "DELETE FROM #{table_name} WHERE "
          sql += Database.quote_identifier(@primary_key.name)
          sql += " = "
          sql += Database.quote_value(id, @primary_key.type)

          Database.execute(sql)
        end
      end
    end
  end
end
