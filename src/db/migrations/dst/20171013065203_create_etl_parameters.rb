Sequel.migration do
  up do
    create_table(dbschema(:etl_parameters)) do
      primary_key :id, type: 'INT'
      String :parameter, size: 100, null: false
      String :value, size: 512, null: false

      index [:parameter], unique: true, name: 'UK_etl_parameters_parameter'
    end
  end

  down do
    drop_table(dbschema(:etl_parameters))
  end
end
