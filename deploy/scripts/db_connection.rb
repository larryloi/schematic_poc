# db_connection.rb
require 'sequel'
require 'tiny_tds'
require 'open3'

#ENV.each do |key, value|
#  if key.start_with?('DST') 
#    puts "#{key}: #{value}"
#  end
#end

def decrypt_credentials
  encrypted_credentials_path = '/app/deploy/cert/keys/encrypted_credentials.bin' 
  private_key_path = '/app/deploy/cert/keys/prikey.key' 
  passphrase = '3aCddqRucVxu2Ub3WqP2g5mziiYb'

  decrypted_credentials, status = Open3.capture2(
    'openssl', 'rsautl', '-decrypt',
    '-inkey', private_key_path,
    '-in', encrypted_credentials_path,
    '-passin', "pass:#{passphrase}"
  )

  raise 'Failed to decrypt credentials' unless status.success?

  decrypted_credentials.strip
end

def db_connection(env)
  db = nil

  decrypted_credentials = decrypt_credentials
  user, password = decrypted_credentials.split(':')

  case env['DB_ADAPTER']
  when 'mysql2'
    db = Sequel.connect(
      adapter: 'mysql2',
      host: env['DB_HOST'],
      database: env['DB_NAME'],
      #user: env['DB_USER'],
      #password: env['DB_PASSWORD'],
      user: user,
      password: password,
      port: env['DB_PORT'],
      fractional_seconds: env['FRACTIONAL_SECONDS'] == "" ? 'true' : env['FRACTIONAL_SECONDS'],
      encoding: env['ENCODING'] == "" ? 'utf8mb4' : env['ENCODING']
    )
  when 'tinytds'
    db = Sequel.connect(
      adapter: 'tinytds',
      host: env['DB_HOST'],
      database: env['DB_NAME'],
      #user: env['DB_USER'],
      #password: env['DB_PASSWORD'],
      user: user,
      password: password,
      port: env['DB_PORT'],
      identifier_input_method: nil
    )
    db.extension(:identifier_mangling)
    db.identifier_input_method = db.identifier_output_method = nil
  else
    raise "Unsupported adapter: #{env['DB_ADAPTER']}"
  end
  db
end