require 'yaml'
require_relative 'db_connection'

# Load YAML data
network_codes_data = YAML.load_file('src/db/seeds/network_codes.yml')
etl_db_maps_data = YAML.load_file('src/db/seeds/etl_db_maps.yml')
etl_table_maps_data = YAML.load_file('src/db/seeds/etl_table_maps.yml')

# Insert data into network_codes table
DB.run("SET IDENTITY_INSERT dbo.network_codes ON")
network_codes_data['network_codes'].each do |data|
  unless DB[:network_codes].where(id: data['id'].to_i).first
    DB[:network_codes].insert(id: data['id'].to_i, name: data['name'], created_at: Time.now.utc, updated_at: Time.now.utc)
  end
end
DB.run("SET IDENTITY_INSERT dbo.network_codes OFF")

# Insert data into etl_db_maps table
DB.run("SET IDENTITY_INSERT dbo.etl_db_maps ON")
etl_db_maps_data['etl_db_maps'].each do |data|
  unless DB[:etl_db_maps].where(id: data['id'].to_i).first
    DB[:etl_db_maps].insert(id: data['id'].to_i, network_code_id: data['network_code_id'], description: data['description'], source_host: data['source_host'], source_db: data['source_db'], dest_host: data['dest_host'], dest_db: data['dest_db'], source_dsn: data['source_dsn'], created_at: Time.now.utc, updated_at: Time.now.utc)
  end
end
DB.run("SET IDENTITY_INSERT dbo.etl_db_maps OFF")

# Insert data into etl_table_maps table
DB.run("SET IDENTITY_INSERT dbo.etl_table_maps ON")
etl_table_maps_data['etl_table_maps'].each do |data|
  unless DB[:etl_table_maps].where(id: data['id'].to_i).first
    etl_table_map_id = DB[:etl_table_maps].insert(id: data['id'].to_i, etl_db_map_id: data['etl_db_map_id'].to_i, transformer: data['transformer'], recipients: data['recipients'], check_delay: 0, created_at: Time.now.utc, updated_at: Time.now.utc)
  end
    # Delete existing records in etl_dest_tables and etl_source_tables tables by etl_table_map_id
    DB[:etl_dest_tables].where(etl_table_map_id: data['id'].to_i).delete
    DB[:etl_source_tables].where(etl_table_map_id: data['id'].to_i).delete

    # Insert child records into etl_dest_tables and etl_source_tables tables
    data['etl_dest_tables'].each do |table|
      DB[:etl_dest_tables].insert(etl_table_map_id: data['id'].to_i, table_name: table['table_name'], created_at: Time.now.utc, updated_at: Time.now.utc)
    end

    data['etl_source_tables'].each do |table|
      DB[:etl_source_tables].insert(etl_table_map_id: data['id'].to_i, table_name: table['table_name'], remark: nil, created_at: Time.now.utc, updated_at: Time.now.utc)
    end
  
end
DB.run("SET IDENTITY_INSERT dbo.etl_table_maps OFF")
