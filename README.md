# schematic
- [schematic](#schematic)
  - [Introduction](#introduction)
      - [Functions](#functions)
      - [SQL Server suport versoin](#sql-server-suport-versoin)
      - [MySQL support version](#mysql-support-version)
  - [Development, Testing phases](#development-testing-phases)
    - [Folder structure](#folder-structure)
    - [How to use?](#how-to-use)
      - [Get the code from github](#get-the-code-from-github)
    - [Objectives](#objectives)
      - [.env (environment file)](#env-environment-file)
      - [docker-compose.yml](#docker-composeyml)
      - [Makefile](#makefile)
      - [docker-env-start.sh and docker-env-stop.sh  (Shell scripts)](#docker-env-startsh-and-docker-env-stopsh--shell-scripts)
    - [Getting start your development.](#getting-start-your-development)
      - [Start up your own environment.](#start-up-your-own-environment)
      - [Prepare your schema migration scripts and stored procedure](#prepare-your-schema-migration-scripts-and-stored-procedure)
      - [Prepare your sample data](#prepare-your-sample-data)
      - [Prepare your Stored Procedure](#prepare-your-stored-procedure)
      - [Prepare your Agent jobs](#prepare-your-agent-jobs)
  - [Build your docker images](#build-your-docker-images)
  - [Deploy to QA and Production environments](#deploy-to-qa-and-production-environments)
  - [Docker Desktop Environment Setup Guide for Windows](#docker-desktop-environment-setup-guide-for-windows)
    - [Introduction](#introduction-1)
    - [Install WSL2](#install-wsl2)
    - [Install Docker Desktop](#install-docker-desktop)
    - [Install VS Code](#install-vs-code)
    - [Install SQL Server Management Studio](#install-sql-server-management-studio)


## Introduction
An Rdb schema migration tools that develop on ruby and Supporting SQL Server and MySQL. This help you to deploy you database schema change. stored procedure and create or update agent job on SQL Server formally and solidly.
#### Functions
  - SQL Server, help to create database schema, and create SQL Server Agent jobs
  - MySQL, help to create database schema.

  #### SQL Server suport versoin
  - SQL Server 2017 (mcr.microsoft.com/mssql/server:2017-CU24-ubuntu-16.04)
  - SQL Server 2019 (mcr.microsoft.com/mssql/server:2019-CU3-ubuntu-18.04)
  - SQL Server 2022 (mcr.microsoft.com/mssql/server:2022-CU8-ubuntu-20.04)

  #### MySQL support version
  - 5.7.x
  - 8.0.x

  

## Development, Testing phases
In development phase, we hope to have a environment that build up fast and work independent, with the tools here, build our self-contain a development environment and also prepare some sample data for testing purpose.

### Folder structure
```
.
├── combined.env
├── deploy
│   ├── jobs
│   │   ├── _Arhive_Data
│   │   │   ├── job.env
│   │   │   └── job.yml
│   │   ├── general.env
│   │   ├── general.yml
│   │   └── _Purge_Data
│   │       ├── job.env
│   │       └── job.yml
│   ├── scripts
│   │   ├── agent_jobs_deploy.rb
│   │   ├── alert.rb
│   │   ├── db_connection.rb
│   │   ├── docker-env-start.sh
│   │   ├── docker-env-stop.sh
│   │   ├── sample_data_load.rb
│   │   ├── seed_data_load.rb
│   │   ├── stored_procedure_create.rb
│   │   └── wait-for-it.sh
│   └── tasks
│       └── sequel.rake
├── docker
│   ├── app -> ../
│   ├── combined.env
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── Dockerfile.bak
│   ├── Makefile -> ../Makefile
│   ├── RELEASE -> ../RELEASE
│   └── scripts -> ../deploy/scripts/
├── Gemfile
├── Gemfile.bak
├── Gemfile.lock
├── Makefile
├── Rakefile.rb
├── README.md
├── RELEASE
└── src
    ├── db
    │   ├── migrations
    │   │   ├── dst
    │   │   │   ├── 20171013025857_create_network_codes.rb
...
    │   │   │   ├── 20230904000101_create_user_operation_logs.rb
    │   │   │   └── 20230904000120_user_operation_logs_change_username_length.rb
    │   │   └── src
    │   │       ├── 20220720233750_create_user.rb
    │   │       └── 20230904000101_create_user_operation_logs.rb
    │   ├── mssql-init
    │   │   ├── configure-db.sh
    │   │   ├── setup.sql
    │   │   └── wait-for-it.sh
    │   ├── seeds
    │   │   ├── etl_db_maps.yml
    │   │   ├── etl_table_maps.yml
    │   │   └── network_codes.yml
    │   └── stored_procedures
    │       ├── create_sp_user_operation_logsA.sql
    │       └── create_sp_user_operation_logs.sql
    └── sample_data
        └── schematic
            └── src
                ├── 001_Users.json
                └── 002_user_operation_logs.json
```

  - config
    - contains agent job configuration or others
  - src/db/migrations
    - contains schema migration scripts
  - src/db/stored_procedures
    - contains stored procedure to be deployed
  - src/db/mssql-init
    - contains docker base SQL Server initail scripts
  - docker
    - contains docker environment configuration
  - src/sample_data
    - sample data directory
  - deploy/scripts
    - contains major logic for schema migration, loading sample data, create agent jobs
  - deploy/tasks
    - ruby sequel rake tasks

### How to use?
  #### Get the code from github
  ```bash
  git clone https://github.com/larryloi/schematic.git
  ```

  ### Objectives
  1. Build a smooth deploy schema migration process.
  2. Build a Self contain development environment.
  It will be assumpted 2 SQL server db required. For example source DB and destination DB. and some source/ destincation tables are required for ETL job logic development. We will only have to develop, schema migration scripts, ETL job logic, Agent job configuration. below some file spec we have to realise. 

  #### .env (environment file)
  that contains our necessary environment variables during our development or test like below.

  ```bash
IMAGE=schematic
TAG=0.1.0

ENV=test
MIGRATION_BASE=db/migrations

SRC_DB_ADAPTER=tinytds
SRC_DB_USER=schematic
SRC_DB_PASSWORD=schematic123
SRC_DB_HOST=centos7
SRC_DB_PORT=1433
SRC_DB_NAME=schematic_test_src
SRC_DB_SCHEMA=SourceSchema
SRC_SCHEMA_TABLE=schema_migrations
...
  ```

  #### docker-compose.yml
  https://docs.docker.com/get-started/08_using_compose/

  It lets you define and run multiple Docker containers using a single file. This file uses the YAML syntax. It can be used to depoy both stateless and stateful applications

  ```yaml
  version: "3"

services:
  db:
    image: mcr.microsoft.com/mssql/server:2017-CU24-ubuntu-16.04
    hostname: "${DST_DB_HOST}"
    env_file:
      - .env
    container_name: schematic-db
    environment:
      ACCEPT_EULA: Y
      SA_PASSWORD: Vg6gEcSGL7p8KbCN
      MSSQL_DATABASE: schematic_test_dst
      MSSQL_SCHEMA: schematic
      #MSSQL_COLLATION: Latin1_General_CS_AS
      MSSQL_MEMORY_LIMIT_MB: 2048
      MSSQL_AGENT_ENABLED: 1
      MSSQL_PID: "Developer"
    ports:
      - 1433:1433
    volumes:
      - schematic_db:/var/opt/mssql
      - ../db/mssql-init:/mssql-init
    networks:
      - integration
      ...
  ```
  #### Makefile
  https://opensource.com/article/18/8/what-how-makefile

  This is a handy automation tool that you could customize your command aliases. and make you development work efficiently.

below is sample contents in Makefile
```Makefile
#!make
include .env
export $(shell sed 's/=.*//' .env)
include RELEASE
export $(shell sed 's/=.*//' RELEASE)
APP_SRC_PATH := $(realpath ../)
WORKDIR := /app
SAMPLE_DATA_PATH_LOCAL := $(realpath ../sample_data)
SAMPLE_DATA_PATH_CT := /app/sample_data

build:
	docker build -f Dockerfile app -t $(IMAGE):$(TAG)

run:
	docker run -d --env-file .env $(IMAGE):$(TAG)

bash:
	docker run --rm -it --env-file .env -v $(APP_SRC_PATH):$(WORKDIR) -v $(SAMPLE_DATA_PATH_LOCAL):$(SAMPLE_DATA_PATH_CT) $(IMAGE):$(TAG) /bin/bash

rmi:
	docker rmi $$(docker images|grep ${REPO_PATH}${IMAGE} | grep ${TAG} |head -1 |awk '{print $$3}')

  ...
```

In this sample, 

if you would like to build a docker image. 

you just only type "make build". 

then make command will execute "docker build -f Dockerfile app -t $(IMAGE):$(TAG)"

and so on


#### docker-env-start.sh and docker-env-stop.sh  (Shell scripts)
docker environment startup and shutdown scripts.


  
The above file we will use always during development.

---
### Getting start your development.

#### Start up your own environment.
Before your new development. we have to prepare DB source and destination. To achieve it, run the below.
After executed the below commands, SQL Server will be bring online. 

  ```bash
  cd docker
  bash ./scripts/docker-env-start.sh
  ```

#### Prepare your schema migration scripts and stored procedure
The below paths save our schema migration scripts. which is ruby sequel syntax

  - db/migrations/dst
  - db/migrations/src


File name kinda 20171013025857_create_network_codes.rb which
naming convertion is datetime with seconds precision then method and object name at the end.

http://sequel.jeremyevans.net/rdoc/files/doc/migration_rdoc.html

Sample migration script here
  ```ruby
Sequel.migration do
  up do
    create_table(dbschema(:etl_table_maps)) do
      primary_key :id, type: 'INT'
      foreign_key :etl_db_map_id, dbschema(:etl_db_maps), null: false
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
    drop_table(dbschema(:etl_table_maps))
  end
end
  ```

To run the schema migration in your docker environment. execute the below command
```bash
cd docker

make src.sch.up    # schema migration for source DB

make dst.sch.up    # schema migration for destination DB
```

Schema migration meta will be saved in table [schema_migrations]; and you will see all the schema migration script entris there if run.


#### Prepare your sample data

In the root path. there is a symbolic link which is storing your sample data

- sample_data -> ../schematic_sample_data

  the folder structure is like below
```
.
└── schematic
    └── src
        ├── 001_Users.json
        └── 002_user_operation_logs.json
```
We could customise our own sample data as our expect. data file is json format. The sample data loader will read the data file by it's filename sequence; 001_Users.json will be loaded first then 002_user_operation_logs.json in the above case. we may control the table dependency.

the datafile sample as below; the key name on the top level indicate the table name. the loader will load it array of value into table accordingly.

```json
{
    "Users": [
        {
            "id": 1,
            "name": "John Wick",
            "email": "John.Wick@pm.me",
            "status": "active",
            "created_at": "2023-09-05T08:45:40",
            "updated_at": "2023-09-05T08:45:40"
        },
        {
            "id": 2,
            "name": "Briana",
            "email": "Briana@pm.mw",
            "status": "active",
            "created_at": "2023-09-05T08:45:12",
            "updated_at": "2023-09-05T08:45:12"
        },
        {
            "id": 3,
            "name": "Pharaoh",
            "email": "Pharaoh@pm.me",
            "status": "active",
            "created_at": "2023-09-04T19:01:45",
            "updated_at": "2023-09-04T19:01:45"
        }
    ]
}
```

You may create your sample data manually. or copy some existing data if it is avaliable. With the below query hints, you may get a json string and build you sample data files. Easy....

```sql
SELECT TOP (1000) [id]
      ,[name]
      ,[email]
      ,[status]
      ,[created_at]
      ,[updated_at]
  FROM [schematic_test_src].[dbo].[Users]
FOR JSON AUTO;
```

To run the sample data loading in your docker environment. execute the below command
```bash
cd docker

make src.data.load    # sample data load into source DB
```


#### Prepare your Stored Procedure

After we have our sample data; we may start the ETL job development. and save the stored procedures into 

- src/db/stored_procedures/create_sp_user_operation_logsA.sql

which is SQL syntax

We have to enforce below deploy a new version stored procedure everytime. create or overwrite it as below sample.

```sql
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
```

To create the stored procedrue into docker environment run the below command
```bash
cd docker

make dst.sp.deploy    # Deploying job into target DB
```



#### Prepare your Agent jobs
Agent jobs config is control by a config file below which is a yaml format.
- Job config
  - deploy/jobs/general.yml
  - deploy/jobs/*/job.yml

general.yml is common config

*/job.yml are job specific configuration that could overwrite the common config, * sign is directory names are expected job name

- Job environment variables
  - deploy/jobs/general.env
  - deploy/jobs/*/job.env

general.env holds common environments
*/job.env are job specific environment variables that could overwrite the common environment variables, * sign is directory names are expected job name


here is a sample
```yaml
---
agent_jobs:
  job_general:
    categroy_name: _Data_Maintenance
    owner_login_name: schematic
    database_name: schematic_test_dst
    enabled: <%= ENV['ENABLED'] || "true" %>                                  # Indicates the status of the added job
    notify_level_email: <%= ENV['NOTIFY_LEVEL_EMAIL'] || "false" %>           # 0: Never, 1: Onsuccess, 2: On failure, 3: Always
    notify_level_netsend: <%= ENV['NOTIFY_LEVEL_NETSEND'] || "false" %>       # 0: Never, 1: Onsuccess, 2: On failure, 3: Always
    notify_level_page: <%= ENV['NOTIFY_LEVEL_PAGE'] || "false" %>             # 0: Never, 1: Onsuccess, 2: On failure, 3: Always
    delete_level: <%= ENV['DELETE_LEVEL'] || "false" %>
  jobs:
    - name: _Archive_Data
      enabled: false
      notify_level_email: false
      notify_level_netsend: false
      notify_level_page: false
      delete_level: false
      description: _Archive_Data
      category_name: _Data_Maintenance
      owner_login_name: schematic
      schedule_name: Test_job_schedule01
      schedule_enabled: <%= ENV['JOB_SCHEDULE_ENABLED'] || "true" %>
      schedule_freq_type: 4 <%= ENV['JOB_SCHEDULE_FREQ_TYPE'] || "4" %>                               # 1: Once, 4: Daily, 8: Weekly, 16: Monthly, 32: Monthly, relative to @freq_interval., 64: Run when the SQL Server Agent service starts, 128: Run when the computer is idle.
      schedule_freq_interval: <%= ENV['JOB_SCHEDULE_FREQ_INTERVAL'] || "1" %>                         # check https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-add-jobschedule-transact-sql?view=sql-server-ver16
      schedule_freq_subday_type: <%= ENV['JOB_SCHEDULE_FREQ_SUBDAY_TYPE'] || "8" %>
      schedule_freq_subday_interval: <%= ENV['JOB_SCHEDULE_FREQ_SUBDAY_INTERVAL'] || "1" %>
      schedule_freq_relative_interval: <%= ENV['JOB_SCHEDULE_FREQ_RELATIVE_INTERVAL'] || "0" %>
      schedule_freq_recurrence_factor: <%= ENV['JOB_SCHEDULE_FREQ_RECURRENCE_FACTOR'] || "0" %>
      schedule_active_start_date: <%= ENV['JOB_SCHEDULE_ACTIVE_START_DATE'] || "20181010" %>
      schedule_active_end_date: <%= ENV['JOB_SCHEDULE_ACTIVE_END_DATE'] || "99991231" %>
      schedule_active_start_time: <%= ENV['JOB_SCHEDULE_ACTIVE_START_TIME'] || "600" %>
      schedule_active_end_time: <%= ENV['JOB_SCHEDULE_ACTIVE_END_TIME'] || "235959" %>
      step_general:
        cmdexec_success_code: 0
        retry_attempts: 0
        retry_interval: 0
        os_run_priority: 0
      job_steps:
        - id: 1
          name: Executing sp_user_operation_logs
          on_success_action: 3                      # 1: Quit with success, 2: Quit with failure, 3: Go to next step, 4: Go to step @on_success_step_id
          on_fail_action: 2                         # 1: Quit with success, 2: Quit with failure, 3: Go to next step, 4: Go to step @on_fail_step_id
          os_run_priority: 0
          subsystem: TSQL
          command: |
            EXEC sp_user_operation_logs;
            GO;
            SELECT GETDATE();
            GO;
        - id: 2
          on_success_action: 1
          on_fail_action: 2
          os_run_priority: 0
          subsystem: TSQL
          command: EXEC sp_user_operation_logsA
```

For more information about the create jobs parameters, go to 

https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-add-job-transact-sql?view=sql-server-ver16

To run the create agent job in your docker environment. execute the below command
```bash
cd docker

make dst.job.deploy    # Deploying job into target DB
```


---
## Build your docker images
There is a RELEASE file under the root path that control the image name and tag
```bash
[root@centos7 schematic]# cat RELEASE
IMAGE=schematic
TAG=0.1.0
```
Before you build the images; ensure what the image name ang tag name in the RELEASE file. and run below command
```bash
make build
```

---
## Deploy to QA and Production environments
In QA and production environments which is kubernetes environments that need us to provide below stuff to put into config map, so that the container can be kicked start .

- Docker image name and tag name; which is sort of ``schematic:0.1.0`` in this sample
- environment variables in ``.env`` file
- agent job config file ``config/agent_jobs.yml``
- bash commands that container need to run; The docker images set ENTRYPOINT ["/bin/bash", "-c"] to accept command injected from external, in our case, the below commands for schema migration, stored procedures and agent job deploy

For schema migration
```
make dst.sch.up
```

For Stored procedure deployment
```
make dst.sp.deploy
```

For agent job deployment
```
make dst.job.deploy
```

---
## Docker Desktop Environment Setup Guide for Windows

### Introduction
This guide provides detailed steps for setting up a Docker Desktop environment on Windows 10 and 11.

### Install WSL2
1. **Check System Requirements:** Make sure you are running Windows 10 version 2004 and higher (Build 19041 and higher) or Windows 11.
2. **Enable WSL:** Open PowerShell as Administrator and run: 
   
   ```dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart```
3. **Enable Virtual Machine Platform:** In the same PowerShell window, run: 
   
    ```dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart```

4. **Install a Linux Distribution:**
   
   a. Visit the Microsoft Store, search for your preferred Linux distribution (like Ubuntu), and click Install. 

    b. by command: list availabe distribution; and install by specific distribution. 
    
    ```wsl —-list —-online```

    ```wsl —-install -d Ubuntu-22.04```
   
5. **Set WSL2 as Default:** In the same PowerShell window, run:

    ```wsl --set-default-version 2```

### Install Docker Desktop
1. **Check System Requirements:** Make sure your system meets the requirements for Docker Desktop.
2. **Download Docker Desktop:** Visit the Docker Desktop download page.
3. **Install Docker Desktop:** Run the installer (Docker Desktop Installer.exe) to start the installation process.
4. **Enable WSL 2 backend:** During installation, ensure the “Use WSL 2 instead of Hyper-V” option on the Configuration page is selected.

### Install VS Code
1. **Download VS Code:** Visit the Visual Studio Code download page.
2. **Connect to WSL from VS Code:** Press F1 in VS Code, select “WSL: Connect to WSL” for the default distro or “WSL: Connect to WSL using Distro” for a specific distro.

### Install SQL Server Management Studio
1. **Download SQL Server Management Studio (SSMS):** Visit the SSMS download page.
2. **Install SSMS:** Run the installer to start the installation process.
