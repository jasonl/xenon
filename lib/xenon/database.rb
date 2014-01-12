require 'pg'

class Xenon::Database
  def self.connection
    @connection ||= connect_to_database
  end

  def self.quote_identifier(identifier)
    connection.escape_identifier(identifier)
  end

  def self.quote_attribute(attr)
    quote_value(attr.get, attr.type)
  end

  def self.quote_value(attr, type)
    case type
    when :integer
      attr.to_i.to_s
    when :string, :text
      "'" + @connection.escape_string(attr.to_s) + "'"
    else
      raise "Unknown attribute type"
    end
  end

  private
  def self.connect_to_database
    conn = PG.connect(dbname: 'xenon_development', user: 'jason')
  end
end
