Sequel.migration do
  up do
    alter_table(dbschema(:user_operation_logs)) do
      set_column_type :username, String, size: 255
    end
  end

  down do
    alter_table(dbschema(:user_operation_logs)) do
      set_column_type :username, String, size: 85
    end
  end
end
