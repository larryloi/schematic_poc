Sequel.migration do
  up do
    create_table(dbschema(:etl_dest_tables)) do
      primary_key :id, type: 'INT'
      foreign_key :etl_table_map_id, dbschema(:etl_table_maps), null: false
      String :table_name, size: 50, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end

  down do
    drop_table(dbschema(:etl_dest_tables))
  end
end
