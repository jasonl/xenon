module Xenon
  module DataDefinitionLanguage
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      # Determines if the table backing this model actually exists in the DB.
      #
      # @return [Boolean] true if the table exists
      def table_exists?
        result = Database.execute(table_exists_sql)
        result[0] && result[0]["count"].to_i > 0
      end
      
      # @private
      # Generates the SQL to test for the existence of a table. This may need to be checked
      # that it is confined to the particular database, rather than the public schema.
      def table_exists_sql
        sql = "SELECT COUNT(*) FROM pg_class WHERE relname='#{table_name}' AND relkind='r'"
      end
      
      # Returns information about the table as it exists in the DB.
      #
      # @return [Xenon::Column] with details of the columns. No guarantees as to column order.
      def table_information
        result = Database.execute(table_information_sql)
        result.map { |tuple| Column.initialize_from_db_tuple(tuple) }
      end
      
      # @private
      # Generates the SQL to return the column information for the table. Again, this is
      # not scoped to a particular schema.
      def table_information_sql
        <<-SQL
        SELECT
                a.attname AS name,
                CASE 
                    WHEN atttypmod = -1 THEN null
                    ELSE (atttypmod - 4) & 65535
                END AS size,
                t.typname AS type,
                CASE WHEN a.attnotnull = 't' THEN 't' ELSE 'f' END AS not_null,
                CASE WHEN r.contype = 'p' THEN 't' ELSE 'f' END AS primary_key
        FROM
                pg_class c 
                JOIN pg_attribute a ON a.attrelid = c.oid
                JOIN pg_type t ON a.atttypid = t.oid
                LEFT JOIN pg_catalog.pg_constraint r ON c.oid = r.conrelid AND a.attnum = ANY(r.conkey)
        WHERE
                c.relname = '#{table_name}'
                AND a.attnum > 0
        SQL
      end
      
      # Creates the table. Will raise an error if it already exists.
      def create_table
        Database.execute(create_table_sql)
      end
      
      # @private
      # Creates the SQL to create a table in the database with columns as defined
      # by the model attributes.
      #
      # @return String
      def create_table_sql
        raise "Primary key not defined for #{self.class.name}" if @primary_key.nil?
        
        sql = "CREATE TABLE #{table_name} "
        sql += "("
        sql += @columns.map { |name, attr| attr.schema_sql_fragment }.join(", ")
        sql += ");"
        sql
      end
      
      # Adds a new column to the database to back the column object supplied
      def add_column(column)
        Database.execute(add_column_sql(column))
      end
      
      # @private
      # Generates the SQL to add a column to the table
      #
      # @return String
      def add_column_sql(column)
        "ALTER TABLE #{table_name} ADD COLUMN #{column.schema_sql_fragment}"
      end
      
      # Drops a column from the table
      def drop_column(column_name)
        Database.execute(drop_column_sql(column_name))
      end
      
      # @private
      # Generates the SQL to drop a column
      #
      # @return String
      def drop_column_sql(column_name)
        "ALTER TABLE #{table_name} DROP COLUMN #{column_name}"
      end 
    end
  end
end