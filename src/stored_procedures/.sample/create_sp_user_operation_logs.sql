IF EXISTS (SELECT * FROM sys.objects o JOIN sys.schemas s ON o.schema_id = s.schema_id WHERE type = 'P' AND o.name = 'sp_user_operation_logs' AND s.name = 'dbo')
BEGIN
    DROP PROCEDURE [dbo].[sp_user_operation_logs]
END
GO

CREATE PROCEDURE [dbo].[sp_user_operation_logs]
AS
BEGIN
    MERGE user_operation_logs AS target
    USING (
        SELECT u.name as username, l.operation, l.operated_at, l.created_at, l.updated_at 
        FROM schematic_src_test.dbo.Users u
        JOIN schematic_src_test.dbo.user_operation_logs l ON u.id = l.user_id
    ) AS source
    ON target.username = source.username AND target.operated_at = source.operated_at
    WHEN MATCHED THEN
        UPDATE SET 
            target.operation = source.operation,
            target.created_at = source.created_at,
            target.updated_at = source.updated_at
    WHEN NOT MATCHED THEN
        INSERT (username, operation, operated_at, created_at, updated_at)
        VALUES (source.username, source.operation, source.operated_at, source.created_at, source.updated_at);
END;

