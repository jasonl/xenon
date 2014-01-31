require 'pg'

class Xenon::Database
  def self.connection
    @connection ||= connect_to_database
  end

  def self.execute(sql)
    connection.async_exec(sql)
  end

  def self.quote_identifier(identifier)
    connection.escape_identifier(identifier)
  end

  def self.quote_attribute(attr)
    quote_value(attr.get, attr.type)
  end

  def self.quote_value(value, type)
    return "NULL" if value.nil?

    case type
    when :integer
      value.to_i.to_s
    when :string, :text
      "'" + @connection.escape_string(value.to_s) + "'"
    else
      raise "Unknown attribute type"
    end
  end

  private
  def self.connect_to_database
    conn = PG.connect(dbname: 'xenon_development', user: 'jason')
    conn.async_exec("SET client_min_messages TO WARNING")
    conn
  end
end
