# db_connection.rb
require 'sequel'
require 'tiny_tds'

#ENV.each do |key, value|
#  if key.start_with?('DST') 
#  #if key.end_with?('LEVEL')
#    puts "#{key}: #{value}"
#  end
#end

def db_connection(env)
  db = nil
  case env['DB_ADAPTER']
  when 'mysql2'
    db = Sequel.connect(
      adapter: 'mysql2',
      host: env['DB_HOST'],
      database: env['DB_NAME'],
      user: env['DB_USER'],
      password: env['DB_PASSWORD'],
      port: env['DB_PORT'],
      fractional_seconds: env['FRACTIONAL_SECONDS'] == "" ? 'true' : env['FRACTIONAL_SECONDS'],
      encoding: env['ENCODING'] == "" ? 'utf8mb4' : env['ENCODING']
    )
  when 'tinytds'
    db = Sequel.connect(
      adapter: 'tinytds',
      host: env['DB_HOST'],
      database: env['DB_NAME'],
      user: env['DB_USER'],
      password: env['DB_PASSWORD'],
      port: env['DB_PORT'],
      identifier_input_method: nil
    )
  else
    raise "Unsupported adapter: #{env['DB_ADAPTER']}"
  end
  db
end