require_relative 'db_connection'
require 'sequel'
require 'pathname'

# Directory where the stored procedures are saved
dir = Pathname.new('src/db/stored_procedures')

# Loop through each file in the directory
Dir.glob(dir.join('*.sql')) do |file|
  # Read the contents of the file
  sql = File.read(file)

  # Execute the SQL
  DB.run(sql)
end


