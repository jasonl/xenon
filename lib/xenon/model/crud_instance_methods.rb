module Xenon
  class Model
    module CrudInstanceMethods
      def delete
        sql = "DELETE FROM #{_table_name} WHERE "
        sql += Database.connection.escape_identifier(_primary_key.name)
        sql += " = "
        sql += Database.connection.escape_string(@attributes[_primary_key.name.to_sym].get)

        Database.connection.async_exec(sql)
      end
    end
  end
end
