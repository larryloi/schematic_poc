Sequel.migration do
  up do
    create_table(:user_operation_logs) do
      primary_key :id, type: 'INT', auto_increment: true
      foreign_key :user_id, :Users, null: false
      String :operation, size: 85, null: false
      DateTime :operated_at, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end

  down do
    drop_table(:user_operation_logs)
  end
end
