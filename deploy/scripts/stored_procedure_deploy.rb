require_relative 'db_connection'
require 'yaml'
require 'erb'
require 'sequel'
require 'tiny_tds'
require 'pathname' 

# Directory where the stored procedures are saved
dir = Pathname.new('/app/src/stored_procedures')


sp_env = {
  'DB_ADAPTER' => 'tinytds',
  'DB_HOST' => ENV['SP_DB_HOST'],
  'DB_NAME' => ENV['SP_DB_NAME'],
  #'DB_USER' => ENV['SP_DB_USER'],
  #'DB_PASSWORD' => ENV['SP_DB_PASSWORD'],
  'DB_PORT' => ENV['SP_DB_PORT']
}

sp_db = db_connection(sp_env)


# Loop through each file in the directory
Dir.glob(dir.join('*.sql')) do |file|
  # Read the contents of the file
  sql = File.read(file)

  # Interpolate the schema into the SQL script
  sql.gsub!('[dbo]', "[#{ENV['SP_DB_SCHEMA']}]")
  sql.gsub!("s.name = 'dbo'", "s.name = '#{ENV['SP_DB_SCHEMA']}'")

  # Split the SQL script into separate commands at each 'GO' statement
  commands = sql.split('GO')
  puts "  >> Executing script from #{file}\n---------------------------------------------\n"
  #puts sql
  commands.each do |command|
    sp_db.run(command) unless command.strip.empty?
  end
end


