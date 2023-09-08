
        declare @MasterPath nvarchar(512)
        declare @LogPath nvarchar(512)
        declare @ErrorLog nvarchar(512)
        declare @ErrorLogPath nvarchar(512)
        declare @Slash varchar = convert(varchar, serverproperty('PathSeparator'))
        select @MasterPath=substring(physical_name, 1, len(physical_name) - charindex(@Slash, reverse(physical_name))) from master.sys.database_files where name=N'master'
        select @LogPath=substring(physical_name, 1, len(physical_name) - charindex(@Slash, reverse(physical_name))) from master.sys.database_files where name=N'mastlog'
        select @ErrorLog=cast(SERVERPROPERTY(N'errorlogfilename') as nvarchar(512))
        select @ErrorLogPath=IIF(@ErrorLog IS NULL, N'', substring(@ErrorLog, 1, len(@ErrorLog) - charindex(@Slash, reverse(@ErrorLog))))
      


        declare @SmoRoot nvarchar(512)
        exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\Setup', N'SQLPath', @SmoRoot OUTPUT
      


SELECT
CAST(case when 'a' <> 'A' then 1 else 0 end AS bit) AS [IsCaseSensitive],
@@MAX_PRECISION AS [MaxPrecision],
@ErrorLogPath AS [ErrorLogPath],
@SmoRoot AS [RootDirectory],
SERVERPROPERTY('PathSeparator') AS [PathSeparator],
CAST(FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') AS bit) AS [IsFullTextInstalled],
@LogPath AS [MasterDBLogPath],
@MasterPath AS [MasterDBPath],
SERVERPROPERTY(N'ProductVersion') AS [VersionString],
CAST(SERVERPROPERTY(N'Edition') AS sysname) AS [Edition],
CAST(SERVERPROPERTY(N'ProductLevel') AS sysname) AS [ProductLevel],
CAST(SERVERPROPERTY('IsSingleUser') AS bit) AS [IsSingleUser],
CAST(SERVERPROPERTY('EngineEdition') AS int) AS [EngineEdition],
convert(sysname, serverproperty(N'collation')) AS [Collation],
CAST(ISNULL(SERVERPROPERTY(N'MachineName'),N'') AS sysname) AS [NetName],
CAST(ISNULL(SERVERPROPERTY('IsClustered'),N'') AS bit) AS [IsClustered],
SERVERPROPERTY(N'ResourceVersion') AS [ResourceVersionString],
SERVERPROPERTY(N'ResourceLastUpdateDateTime') AS [ResourceLastUpdateDateTime],
SERVERPROPERTY(N'CollationID') AS [CollationID],
SERVERPROPERTY(N'ComparisonStyle') AS [ComparisonStyle],
SERVERPROPERTY(N'SqlCharSet') AS [SqlCharSet],
SERVERPROPERTY(N'SqlCharSetName') AS [SqlCharSetName],
SERVERPROPERTY(N'SqlSortOrder') AS [SqlSortOrder],
SERVERPROPERTY(N'SqlSortOrderName') AS [SqlSortOrderName],
SERVERPROPERTY(N'BuildClrVersion') AS [BuildClrVersionString],
ISNULL(SERVERPROPERTY(N'ComputerNamePhysicalNetBIOS'),N'') AS [ComputerNamePhysicalNetBIOS],
CAST(SERVERPROPERTY('IsPolyBaseInstalled') AS bit) AS [IsPolyBaseInstalled]


---

exec sp_executesql N'SELECT
dtb.collation_name AS [Collation],
dtb.name AS [DatabaseName2]
FROM
master.sys.databases AS dtb
WHERE
(dtb.name=@_msparam_0)',N'@_msparam_0 nvarchar(4000)',@_msparam_0=N'master'

---

RPC:Completed	exec sp_executesql N'SELECT
dtb.name AS [Name]
FROM
master.sys.databases AS dtb
WHERE
(dtb.name=@_msparam_0)',N'@_msparam_0 nvarchar(4000)',@_msparam_0=N'msdb'	Microsoft SQL Server Management Studio		sa	1	8	0	1	10196	66	2023-09-05 08:33:26.490	2023-09-05 08:33:26.490	0X00000000040000001A00730070005F006500780065006300750074006500730071006C00D400000082001800E7206E0076006100720063006800610072002800380037002900AE00000053004500	


---

RPC:Completed	exec sp_executesql N'SELECT
dtb.collation_name AS [Collation],
dtb.name AS [DatabaseName2]
FROM
master.sys.databases AS dtb
WHERE
(dtb.name=@_msparam_0)',N'@_msparam_0 nvarchar(4000)',@_msparam_0=N'msdb'	Microsoft SQL Server Management Studio		sa	1	8	0	2	10196	66	2023-09-05 08:33:26.493	2023-09-05 08:33:26.497	0X00000000040000001A00730070005F006500780065006300750074006500730071006C002E01000082001A00E7206E0076006100720063006800610072002800310033003100290006010000530045004C004500430054000A006400740062002E006300	

----

SQL:BatchCompleted	SELECT
sv.name AS [Name],
sv.category_id AS [CategoryID],
sv.job_id AS [JobID]
FROM
msdb.dbo.sysjobs_view AS sv
ORDER BY
[Name] ASC	Microsoft SQL Server Management Studio		sa	6	42	0	6	10196	66	2023-09-05 08:33:26.500	2023-09-05 08:33:26.507		


----

RPC:Completed	exec sp_executesql N'
create table #tmp_sp_help_category
(category_id int null, category_type tinyint null, name nvarchar(128) null)
insert into #tmp_sp_help_category (category_id, category_type, name) exec msdb.dbo.sp_help_category ''JOB''
		


SELECT
tshc.name AS [Name]
FROM
#tmp_sp_help_category AS tshc
WHERE
(tshc.name=@_msparam_0)

drop table #tmp_sp_help_category
		
',N'@_msparam_0 nvarchar(4000)',@_msparam_0=N'DataService-ETL-Jobs'	Microsoft SQL Server Management Studio		sa	4	311	1	4	10196	66	2023-09-05 08:33:26.593	2023-09-05 08:33:26.597	0X00000000040000001A00730070005F006500780065006300750074006500730071006C00F402000082001A00E7206E00760061007200630068006100720028003300350038002900CC0200000D000A0063007200650061007400650020007400610062006C0065002000230074006D0070005F00730070005F00680065006C0070005F00630061007400650067006F00720079000D000A002800630061007400650067006F00720079005F0069006400200069006E00740020006E0075006C006C002C002000630061007400650067006F00720079005F0074007900700065	

----

RPC:Completed	exec sp_executesql N'
create table #tmp_sp_help_category
(category_id int null, category_type tinyint null, name nvarchar(128) null)
insert into #tmp_sp_help_category (category_id, category_type, name) exec msdb.dbo.sp_help_category ''JOB''
		


SELECT
tshc.name AS [Name],
tshc.category_id AS [ID],
tshc.category_type AS [CategoryType]
FROM
#tmp_sp_help_category AS tshc
WHERE
(tshc.name=@_msparam_0)

drop table #tmp_sp_help_category
		
',N'@_msparam_0 nvarchar(4000)',@_msparam_0=N'DataService-ETL-Jobs'	Microsoft SQL Server Management Studio		sa	2	244	0	1	10196	66	2023-09-05 08:33:26.640	2023-09-05 08:33:26.640	0X00000000040000001A00730070005F006500780065006300750074006500730071006C007403000082001A00E7206E007600610072006300680061007200280034003200320029004C0300000D000A0063007200650061007400650020007400610062006C0065002000230074006D0070005F00730070005F00680065006C0070005F00630061007400650067006F00720079000D000A002800630061007400650067006F00720079005F0069006400200069006E00740020006E0075006C006C002C002000630061007400650067006F00720079005F0074007900700065002000740069006E00790069006E00740020006E0075006C006C002C0020006E	

----


SQL:BatchCompleted	DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'sp_user_operation_logs', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'DataService-ETL-Jobs', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
select @jobId	Microsoft SQL Server Management Studio		sa	20	361	11	31	10196	66	2023-09-05 08:33:26.643	2023-09-05 08:33:26.673		

---

RPC:Completed	exec sp_executesql N'SELECT
sv.name AS [Name],
sv.job_id AS [JobID],
sv.originating_server AS [OriginatingServer],
CAST(sv.enabled AS bit) AS [IsEnabled],
ISNULL(sv.description,N'''') AS [Description],
sv.start_step_id AS [StartStepID],
ISNULL(suser_sname(sv.owner_sid), N'''') AS [OwnerLoginName],
sv.notify_level_eventlog AS [EventLogLevel],
sv.notify_level_email AS [EmailLevel],
sv.notify_level_netsend AS [NetSendLevel],
sv.notify_level_page AS [PageLevel],
sv.delete_level AS [DeleteLevel],
sv.date_created AS [DateCreated],
sv.date_modified AS [DateLastModified],
sv.version_number AS [VersionNumber],
sv.category_id AS [CategoryID]
FROM
msdb.dbo.sysjobs_view AS sv
WHERE
(sv.name=@_msparam_0 and sv.category_id=@_msparam_1)',N'@_msparam_0 nvarchar(4000),@_msparam_1 nvarchar(4000)',@_msparam_0=N'sp_user_operation_logs',@_msparam_1=N'102'	Microsoft SQL Server Management Studio		sa	15	44	0	15	10196	66	2023-09-05 08:33:26.680	2023-09-05 08:33:26.697	0X00000000050000001A00730070005F006500780065006300750074006500730071006C00AC05000082001A00E7206E0076006100720063006800610072002800370030003600290084050000530045004C004500430054000A00730076002E006E0061006D00650020004100530020005B004E0061006D0065005D002C000A00730076002E006A006F0062005F006900640020004100530020005B004A006F006200490044005D002C000A00730076002E006F0072006900670069006E006100740069006E0067005F0073006500720076006500720020004100530020005B004F0072006900670069006E006100740069006E00670053006500720076006500	

----

RPC:Completed	exec sp_executesql N'EXECUTE msdb.dbo.sp_sqlagent_refresh_job @job_id = @P1',N'@P1 uniqueidentifier','E1CD350E-AE5D-4505-A73A-17DFF44D95E4'	SQLAgent - Generic Refresher	NETWORK SERVICE	NT AUTHORITY\NETWORK SERVICE	15	655	0	18	276	53	2023-09-05 08:33:26.790	2023-09-05 08:33:26.807	0X00000000040000001A00730070005F006500780065006300750074006500730071006C009400000082001A00E7206E00760061007200630068006100720028006D006100	


----

RPC:Completed	exec sp_executesql N'EXECUTE msdb.dbo.sp_help_jobschedule @job_id = @P1, @include_description = 0',N'@P1 uniqueidentifier','E1CD350E-AE5D-4505-A73A-17DFF44D95E4'	SQLAgent - Generic Refresher	NETWORK SERVICE	NT AUTHORITY\NETWORK SERVICE	9	354	6	9	276	53	2023-09-05 08:33:26.810	2023-09-05 08:33:26.820	0X00000000040000001A00730070005F006500780065006300750074006500730071006C00C000000082001A00E7206E00760061007200630068006100720028006D0061007800290098000000450058	


----

exec sp_executesql N'EXECUTE [msdb].[dbo].[sp_sqlagent_create_jobactivity] @session_id = @P1, @job_id = @P2, @is_system = @P3',N'@P1 int,@P2 uniqueidentifier,@P3 int',7,'E1CD350E-AE5D-4505-A73A-17DFF44D95E4',0

---

exec sp_executesql N'EXECUTE [msdb].[dbo].[sp_sqlagent_update_jobactivity_next_scheduled_date] @session_id = @P1, @job_id = @P2, @is_system = @P3, @last_run_date = NULL, @last_run_time = NULL',N'@P1 int,@P2 uniqueidentifier,@P3 int',7,'E1CD350E-AE5D-4505-A73A-17DFF44D95E4',0

----

EXEC msdb.dbo.sp_add_jobserver @job_id=N'e1cd350e-ae5d-4505-a73a-17dff44d95e4', @server_name = N'A62A11FDBF12'

----

select category_id from msdb.dbo.sysjobs_view where job_id='e1cd350e-ae5d-4505-a73a-17dff44d95e4'

---

exec sp_executesql N'EXECUTE msdb.dbo.sp_sqlagent_refresh_job @job_id = @P1',N'@P1 uniqueidentifier','E1CD350E-AE5D-4505-A73A-17DFF44D95E4'

---

EXEC msdb.dbo.sp_add_jobstep @job_id=N'e1cd350e-ae5d-4505-a73a-17dff44d95e4', @step_name=N'wait-for', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WAITFOR DELAY ''00:00:03'';', 
		@database_name=N'schematic_dst_test', 
		@flags=0

---

EXEC msdb.dbo.sp_add_jobstep @job_id=N'e1cd350e-ae5d-4505-a73a-17dff44d95e4', @step_name=N'Run-sp_user_operation_logs', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_user_operation_logs', 
		@database_name=N'master', 
		@flags=0

---

exec sp_executesql N'
create table #tmp_sp_help_jobstep
(step_id int null, step_name nvarchar(128) null, subsystem nvarchar(128) collate Latin1_General_CI_AS null, command nvarchar(max) null, flags int null, cmdexec_success_code int null, on_success_action tinyint null, on_success_step_id int null, on_fail_action tinyint null, on_fail_step_id int null, server nvarchar(128) null, database_name sysname null, database_user_name sysname null, retry_attempts int null, retry_interval int null, os_run_priority int null, output_file_name nvarchar(300) null, last_run_outcome int null, last_run_duration int null, last_run_retries int null, last_run_date int null, last_run_time int null, proxy_id int null, job_id uniqueidentifier null)

declare @job_id uniqueidentifier
declare crs cursor local fast_forward
for ( SELECT
sv.job_id AS [JobID]
FROM
msdb.dbo.sysjobs_view AS sv
WHERE
(sv.name=@_msparam_0 and sv.category_id=@_msparam_1) ) 
open crs 
fetch crs into @job_id
while @@fetch_status >= 0 
begin 
	insert into #tmp_sp_help_jobstep(step_id, step_name, subsystem, command, flags, cmdexec_success_code, on_success_action, on_success_step_id, on_fail_action, on_fail_step_id, server, database_name, database_user_name, retry_attempts, retry_interval, os_run_priority, output_file_name, last_run_outcome, last_run_duration, last_run_retries, last_run_date, last_run_time, proxy_id) 
		exec msdb.dbo.sp_help_jobstep @job_id = @job_id
	update #tmp_sp_help_jobstep set job_id = @job_id where job_id is null
	fetch crs into @job_id
end 
close crs
deallocate crs


create table #tmp_sp_help_proxy
(proxy_id int null, name nvarchar(300) null, credential_identity nvarchar(300) null, enabled tinyint null, description nvarchar(max) null, user_sid binary(200) null, credential_id int null, credential_identity_exists int null)
insert into #tmp_sp_help_proxy(proxy_id, name, credential_identity, enabled, description, user_sid, credential_id, credential_identity_exists)
		exec msdb.dbo.sp_help_proxy
		


SELECT
tshj.step_name AS [Name],
tshj.step_id AS [ID],
CASE LOWER(tshj.subsystem) when ''tsql'' THEN 1 WHEN ''activescripting'' THEN 2 WHEN ''cmdexec'' THEN 3 
WHEN ''snapshot'' THEN 4 WHEN ''logreader'' THEN 5 WHEN ''distribution'' THEN 6 
WHEN ''merge'' THEN 7 WHEN ''queuereader'' THEN 8 WHEN ''analysisquery'' THEN 9 
WHEN ''analysiscommand'' THEN 10 WHEN ''dts'' THEN 11 WHEN ''ssis'' THEN 11 WHEN ''powershell'' THEN 12 ELSE 0 END AS [SubSystem],
ISNULL(tshj.command,N'''') AS [Command],
tshj.cmdexec_success_code AS [CommandExecutionSuccessCode],
tshj.on_success_action AS [OnSuccessAction],
tshj.on_success_step_id AS [OnSuccessStep],
tshj.on_fail_action AS [OnFailAction],
tshj.on_fail_step_id AS [OnFailStep],
ISNULL(tshj.server,N'''') AS [Server],
ISNULL(tshj.database_name,N'''') AS [DatabaseName],
ISNULL(tshj.database_user_name,N'''') AS [DatabaseUserName],
tshj.retry_attempts AS [RetryAttempts],
tshj.retry_interval AS [RetryInterval],
tshj.os_run_priority AS [OSRunPriority],
ISNULL(tshj.output_file_name,N'''') AS [OutputFileName],
tshj.last_run_outcome AS [LastRunOutcome],
tshj.last_run_duration AS [LastRunDuration],
tshj.last_run_retries AS [LastRunRetries],
null AS [LastRunDate],
tshj.flags AS [JobStepFlags],
ISNULL(sp.name,N'''') AS [ProxyName],
tshj.last_run_date AS [LastRunDateInt],
tshj.last_run_time AS [LastRunTimeInt]
FROM
msdb.dbo.sysjobs_view AS sv
INNER JOIN #tmp_sp_help_jobstep AS tshj ON tshj.job_id=sv.job_id
LEFT OUTER JOIN #tmp_sp_help_proxy AS sp ON sp.proxy_id = tshj.proxy_id
WHERE
(tshj.step_name=@_msparam_2)and((sv.name=@_msparam_3 and sv.category_id=@_msparam_4))

drop table #tmp_sp_help_jobstep
		


drop table #tmp_sp_help_proxy
		
',N'@_msparam_0 nvarchar(4000),@_msparam_1 nvarchar(4000),@_msparam_2 nvarchar(4000),@_msparam_3 nvarchar(4000),@_msparam_4 nvarchar(4000)',@_msparam_0=N'sp_user_operation_logs',@_msparam_1=N'102',@_msparam_2=N'wait-for',@_msparam_3=N'sp_user_operation_logs',@_msparam_4=N'102'

---

exec sp_executesql N'
			create table #tmp_sp_help_category
			(category_id int null, category_type tinyint null, name nvarchar(128) null)
			insert into #tmp_sp_help_category exec msdb.dbo.sp_help_category
		


SELECT
tshc.name AS [Category]
FROM
msdb.dbo.sysjobs_view AS sv
INNER JOIN #tmp_sp_help_category AS tshc ON sv.category_id = tshc.category_id
WHERE
(sv.name=@_msparam_0 and sv.category_id=@_msparam_1)

drop table #tmp_sp_help_category
		
',N'@_msparam_0 nvarchar(4000),@_msparam_1 nvarchar(4000)',@_msparam_0=N'sp_user_operation_logs',@_msparam_1=N'102'

---

exec sp_executesql N'
				create table #tmp_sp_help_operator
				(id int null, name nvarchar(128) null, enabled tinyint null, email_address nvarchar(100) null, last_email_date int null, last_email_time int null, pager_address nvarchar(100) null, last_pager_date int null, last_pager_time int null, weekday_pager_start_time int null, weekday_pager_end_time int null, saturday_pager_start_time int null, saturday_pager_end_time int null, sunday_pager_start_time int null, sunday_pager_end_time int null, pager_days tinyint null, netsend_address nvarchar(100) null, last_netsend_date int null, last_netsend_time int null, category_name nvarchar(128) null)
				insert into #tmp_sp_help_operator exec msdb.dbo.sp_help_operator
			


SELECT
ISNULL(tsho_e.name,N'''') AS [OperatorToEmail]
FROM
msdb.dbo.sysjobs_view AS sv
LEFT OUTER JOIN #tmp_sp_help_operator AS tsho_e ON tsho_e.id = sv.notify_email_operator_id
WHERE
(sv.name=@_msparam_0 and sv.category_id=@_msparam_1)

drop table #tmp_sp_help_operator
		
',N'@_msparam_0 nvarchar(4000),@_msparam_1 nvarchar(4000)',@_msparam_0=N'sp_user_operation_logs',@_msparam_1=N'102'


---

exec sp_executesql N'
				create table #tmp_sp_help_operator
				(id int null, name nvarchar(128) null, enabled tinyint null, email_address nvarchar(100) null, last_email_date int null, last_email_time int null, pager_address nvarchar(100) null, last_pager_date int null, last_pager_time int null, weekday_pager_start_time int null, weekday_pager_end_time int null, saturday_pager_start_time int null, saturday_pager_end_time int null, sunday_pager_start_time int null, sunday_pager_end_time int null, pager_days tinyint null, netsend_address nvarchar(100) null, last_netsend_date int null, last_netsend_time int null, category_name nvarchar(128) null)
				insert into #tmp_sp_help_operator exec msdb.dbo.sp_help_operator
			


SELECT
ISNULL(tsho_ns.name,N'''') AS [OperatorToNetSend]
FROM
msdb.dbo.sysjobs_view AS sv
LEFT OUTER JOIN #tmp_sp_help_operator AS tsho_ns ON tsho_ns.id = sv.notify_netsend_operator_id
WHERE
(sv.name=@_msparam_0 and sv.category_id=@_msparam_1)

drop table #tmp_sp_help_operator
		
',N'@_msparam_0 nvarchar(4000),@_msparam_1 nvarchar(4000)',@_msparam_0=N'sp_user_operation_logs',@_msparam_1=N'102'

---

exec sp_executesql N'
				create table #tmp_sp_help_operator
				(id int null, name nvarchar(128) null, enabled tinyint null, email_address nvarchar(100) null, last_email_date int null, last_email_time int null, pager_address nvarchar(100) null, last_pager_date int null, last_pager_time int null, weekday_pager_start_time int null, weekday_pager_end_time int null, saturday_pager_start_time int null, saturday_pager_end_time int null, sunday_pager_start_time int null, sunday_pager_end_time int null, pager_days tinyint null, netsend_address nvarchar(100) null, last_netsend_date int null, last_netsend_time int null, category_name nvarchar(128) null)
				insert into #tmp_sp_help_operator exec msdb.dbo.sp_help_operator
			


SELECT
ISNULL(tsho_p.name,N'''') AS [OperatorToPage]
FROM
msdb.dbo.sysjobs_view AS sv
LEFT OUTER JOIN #tmp_sp_help_operator AS tsho_p ON tsho_p.id = sv.notify_page_operator_id
WHERE
(sv.name=@_msparam_0 and sv.category_id=@_msparam_1)

drop table #tmp_sp_help_operator
		
',N'@_msparam_0 nvarchar(4000),@_msparam_1 nvarchar(4000)',@_msparam_0=N'sp_user_operation_logs',@_msparam_1=N'102'

---

exec sp_executesql N'EXECUTE msdb.dbo.sp_sqlagent_refresh_job @job_id = @P1',N'@P1 uniqueidentifier','E1CD350E-AE5D-4505-A73A-17DFF44D95E4'


---

EXEC msdb.dbo.sp_update_job @job_id=N'e1cd350e-ae5d-4505-a73a-17dff44d95e4', 
		@start_step_id=1

----

exec sp_executesql N'EXECUTE msdb.dbo.sp_help_schedule @schedule_id = @P1, @attached_schedules_only = 1, @include_description = 0',N'@P1 int',12

---

exec sp_executesql N'EXECUTE [msdb].[dbo].[sp_sqlagent_update_jobactivity_next_scheduled_date] @session_id = @P1, @job_id = @P2, @is_system = @P3,     @last_run_date = @P4, @last_run_time = @P5',N'@P1 int,@P2 uniqueidentifier,@P3 int,@P4 int,@P5 int',7,'E1CD350E-AE5D-4505-A73A-17DFF44D95E4',0,20230905,83500


---

DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_id=N'e1cd350e-ae5d-4505-a73a-17dff44d95e4', @name=N'sp_user_operation_logs-5mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20230905, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id