Sequel.migration do
  up do
    create_table(dbschema(:network_codes)) do
      primary_key :id, type: 'INT'
      String :name, size: 255, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end

  down do
    drop_table(dbschema(:network_codes))
  end
end