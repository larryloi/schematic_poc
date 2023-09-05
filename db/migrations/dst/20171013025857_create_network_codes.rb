Sequel.migration do
  up do
    create_table(:network_codes) do
      primary_key :id, type: 'INT'
      String :name, size: 255, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end

  down do
    drop_table(:network_codes)
  end
end