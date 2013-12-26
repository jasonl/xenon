require 'pg'

class Xenon::Database
  def self.connection
    @connection ||= connect_to_database
  end

  private
  def self.connect_to_database
    conn = PG.connect(dbname: 'xenon_development', user: 'jason')
  end
end
