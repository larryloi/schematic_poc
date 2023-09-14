Sequel.migration do
  up do
    create_table(:etl_table_maps) do
      primary_key :id, type: 'INT'
      foreign_key :etl_db_map_id, :etl_db_maps, null: false
      String :transformer, size: 255, null: false
      DateTime :data_process_started_at, null: true
      DateTime :data_process_completed_at, null: true
      Integer :data_process_interval, null: true
      String :recipients, size: 255, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      column :check_delay, 'TINYINT', null: false
      column :row_completed_id, 'BIGINT', null: true
      column :row_interval, 'BIGINT', null: true
    end
  end

  down do
    drop_table(:etl_table_maps)
  end
end
