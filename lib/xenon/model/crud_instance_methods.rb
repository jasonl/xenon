module Xenon
  class Model
    module CrudInstanceMethods
      def insert
        sql = "INSERT INTO #{_table_name} ("
        sql += _dirty_attributes.map { |attr|
          Database.quote_identifier(attr.column_name)
        }.join(",")
        sql += ") VALUES ("
        sql += _dirty_attributes.map { |attr|
          Database.quote_attribute(attr)
        }.join(",")
        sql += ")"
        sql += " RETURNING " + Database.quote_identifier(_primary_key.name)

        result = Database.execute(sql)
        self.send(_primary_key.name.to_s + '=', result[0][_primary_key.name.to_s])
        @attributes.each { |attr| attr.reset }
        self
      end

      def update(values)
        self.class.validate_attributes_hash!(values)

        values.each do |name, value|
          @attributes[name.to_sym].set(value)
        end

        sql = "UPDATE #{_table_name} "
        sql += "SET "
        sql_fragments = @attributes.map do |_, attr|
          sql_fragment = Database.quote_identifier(attr.column_name)
          sql_fragment += " = "
          sql_fragment += Database.quote_attribute(attr)
          sql_fragment
        end
        sql += sql_fragments.join(",")
        sql += " WHERE "
        sql += Database.quote_identifier(_primary_key.name)
        sql += " = "
        sql += Database.quote_attribute(@attributes[_primary_key.name.to_sym])

        Database.execute(sql)
        @attributes.each { |attr| attr.reset }
        self
      end

      def delete
        sql = "DELETE FROM #{_table_name} WHERE "
        sql += Database.quote_identifier(_primary_key.name)
        sql += " = "
        sql += Database.quote_attribute(@attributes[_primary_key.name.to_sym])

        Database.execute(sql)
      end
    end
  end
end
