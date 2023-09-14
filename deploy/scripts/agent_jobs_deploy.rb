require_relative 'db_connection'
require 'yaml'
require 'erb'


# Load general configuration
general_config_file = '/app/deploy/jobs/config/general.yml'
general_config = YAML.load(ERB.new(File.read(general_config_file)).result)

puts "  >> Loading general configuration from #{general_config_file}\n---------------------------------------------\n"

# List of job config files
job_config_files = Dir.glob('/app/deploy/jobs/config/job*.yml')

# Begin transaction
DB.transaction do
  # Iterate over job config files
  job_config_files.each do |job_config_file|
    # Load job-specific configuration
    job_config = YAML.load(ERB.new(File.read(job_config_file)).result)

    puts "  >> Loading job-specific configuration from #{job_config_file}\n---------------------------------------------\n"

    # Merge general parameters with job-specific parameters
    # Job-specific parameters will overwrite general parameters if they exist
    job = general_config.merge(job_config)

    # Set variables
    category_name = job['category_name']
    owner_login_name = job['owner_login_name']
    database_name = job['database_name']
    job_name = job['name']
    #schedule_uid = SecureRandom.uuid

    # Check if job exists
    if DB.fetch("SELECT name FROM msdb.dbo.sysjobs WHERE name=?", job_name).count > 0

      # Delete job if exists
      DB.call_mssql_sproc(:sp_delete_job, args:{
        'job_name' => job_name
      })
    end

    # Check if category exists
    if DB.fetch("SELECT name FROM msdb.dbo.syscategories WHERE name=? AND category_class=1", category_name).count == 0

      DB.call_mssql_sproc(:sp_add_category, args: {
        'class' => 'JOB',
        'type' => 'LOCAL',
        'name' => category_name
      })
    end

    # Creating job
    puts "  >> Creating job #{job_name}"
    job_id = DB.call_mssql_sproc(:sp_add_job, args: {
      'job_name' => job_name,
      'enabled' => job['enabled'],
      'notify_level_eventlog' => 0,
      'notify_level_email' => job['notify_level_email'],
      'notify_level_netsend' => job['notify_level_netsend'],
      'notify_level_page' => job['notify_level_page'],
      'delete_level' => job['delete_level'],
      'description' => job['description'],
      'category_name' => category_name,
      'owner_login_name' => owner_login_name,
      'job_id' => [:output, 'uniqueidentifier', 'job_id']
      })[:job_id]


    # Iterate over job steps
    job['job_steps'].each do |step|
      # Merge step_general parameters with step parameters
      step = job['step_general'].merge(step)

      # Add job step
      puts "    >> Adding step #{step['name']}"
      DB.call_mssql_sproc(:sp_add_jobstep, args: {
        'job_id' => job_id,
        'step_id' => step['id'],
        'step_name' => step['name'] || step['command'].split(' ')[1],
        'cmdexec_success_code' => step['cmdexec_success_code'],
        'on_success_action' => step['on_success_action'],
        'on_fail_action' => step['on_fail_action'],
        'retry_attempts' => step['retry_attempts'],
        'retry_interval' => step['retry_interval'],
        'os_run_priority' => step['os_run_priority'],
        'subsystem' => step['subsystem'],
        'command' => step['command'],
        'database_name' => database_name
      })
    end

    # Update start step id of the job
    DB.call_mssql_sproc(:sp_update_job, args: {
      'job_id' => job_id.to_s,
      'start_step_id' => 1
    })


    # Add schedule to the job
    puts "  >> Adding schedule to the job #{job_name}"
    DB.call_mssql_sproc(:sp_add_jobschedule, args: {
      'job_id' => job_id,
      #':schedule_uid, type: :output},
      'name' => job['schedule_name'],
      'enabled' => job['schedule_enabled'],
      'freq_type' => job['schedule_freq_type'].to_i,
      'freq_interval' => job['schedule_freq_interval'].to_i,
      'freq_subday_type' => job['schedule_freq_subday_type'].to_i,
      'freq_subday_interval' => job['schedule_freq_subday_interval'].to_i,
      'freq_relative_interval' => job['schedule_freq_relative_interval'].to_i,
      'freq_recurrence_factor' => job['schedule_freq_recurrence_factor'].to_i,
      'active_start_date' => job['schedule_active_start_date'].to_i,
      'active_end_date' => job['schedule_active_end_date'].to_i,
      'active_start_time' => job['schedule_active_start_time'].to_i,
      'active_end_time' => job['schedule_active_end_time'].to_i
    })

    # Add server to the job
    puts "  >> Adding server to the job #{job_name}\n---------------------------------------------\n"
    DB.call_mssql_sproc(:sp_add_jobserver, args: {
      'job_id' => job_id.to_s,
      'server_name' => '(local)'
    })

  end
end
