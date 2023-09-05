Sequel.migration do
  change do
    create_table(:Users) do
      primary_key :id
      String :name, null: false
      String :email, null: false, unique: true
      String :status, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
