Sequel.migration do
  up do
    create_table(dbschema(:etl_db_maps)) do
      primary_key :id, type: 'INT'
      foreign_key :network_code_id, dbschema(:network_codes), null: false
      String :description, size: 255, null: false
      String :source_host, size: 50, null: false
      String :source_db, size: 50, null: false
      String :dest_host, size: 50, null: false
      String :dest_db, size: 50, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      String :source_dsn, size: 50, null: true
    end
  end

  down do
    drop_table(dbschema(:etl_db_maps))
  end
end
