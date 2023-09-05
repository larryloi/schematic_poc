Sequel.migration do
  up do
    # Load the stored procedure creation script
    run("DROP PROCEDURE IF EXISTS sp_user_operation_logs;")
    stored_procedure_path = '/app/db/stored_procedures/create_sp_user_operation_logs.sql'
    stored_procedure = File.read(stored_procedure_path)

    # Execute the stored procedure creation script
    run stored_procedure
  end

  down do
    run("DROP PROCEDURE IF EXISTS sp_user_operation_logs;")
    # You can add code here to revert the changes made in the up block
  end
end

