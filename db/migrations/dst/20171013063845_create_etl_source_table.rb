Sequel.migration do
  up do
    create_table(:etl_source_tables) do
      primary_key :id, type: 'INT'
      foreign_key :etl_table_map_id, :etl_table_maps, null: false
      String :table_name, size: 50, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      String :remark, size: 4000, null: true
    end
  end

  down do
    drop_table(:etl_source_tables)
  end
end
