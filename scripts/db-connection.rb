# db_connection.rb
require 'sequel'
require 'tiny_tds'

case ENV['DB_ADAPTER']
when 'mysql2'
  DB = Sequel.connect(
    adapter: 'mysql2',
    host: ENV['DB_HOST'],
    database: ENV['DB_DATABASE'],
    user: ENV['DB_USER'],
    password: ENV['DB_PASSWORD'],
    port: ENV['DB_PORT'],
    fractional_seconds: ENV['FRACTIONAL_SECONDS'] == "" ? 'true' : ENV['FRACTIONAL_SECONDS'],
    encoding: ENV['ENCODING'] == "" ? 'utf8mb4' : ENV['ENCODING']
  )
when 'tinytds'
  DB = Sequel.connect(
    adapter: 'tinytds',
    host: ENV['DB_HOST'],
    database: ENV['DB_DATABASE'],
    user: ENV['DB_USER'],
    password: ENV['DB_PASSWORD'],
    port: ENV['DB_PORT'],
    identifier_input_method: nil
    #identifier_output_method: nil,
    #extension: identifier_mangling
  )
else
  raise "Unsupported adapter: #{ENV['DB_ADAPTER']}"
end

