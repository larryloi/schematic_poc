require_relative '../scripts/db_connection'
require 'sequel'
require 'bundler/setup'
require 'bundler'
require 'yaml'
require 'json'
require 'tiny_tds'
require 'open3'

def dbschema(table_name)
  Sequel[ENV['DB_SCHEMA'].to_sym][table_name]
end


namespace :db do

    namespace :migrate do
      Sequel.extension :migration


      task :connect do
 
        sch_env = {
          'DB_ADAPTER' => 'tinytds',
          'DB_HOST' => ENV['DB_HOST'],
          'DB_NAME' => ENV['DB_NAME'],
          #'DB_USER' => ENV['JOB_DB_USER'],
          #'DB_PASSWORD' => ENV['JOB_DB_PASSWORD'],
          'DB_PORT' => ENV['DB_PORT']
        }
        
        DB = db_connection(sch_env)
      end

      desc "generates a migration file with a timestamp and name"
      task :generate, :name do |_, args|
        args.with_defaults(name: 'migration')

        migration_template = <<~MIGRATION
          Sequel.migration do
            up do
            end

            down do
            end
          end
        MIGRATION

        file_name = "#{Time.now.strftime('%Y%m%d%H%M%S')}_#{args.name}.rb"
        FileUtils.mkdir_p(ENV['MIGRATION_PATH'])

        File.open(File.join(ENV['MIGRATION_PATH'], file_name), 'w') do |file|
          file.write(migration_template)
        end
      end

      desc 'Perform migration reset (full erase and migration up).'
      task :reset => [:connect] do
        Sequel::Migrator.run(DB, ENV['MIGRATION_PATH'], :target => 0, :allow_missing_migration_files => true)
        Sequel::Migrator.run(DB, ENV['MIGRATION_PATH'], :allow_missing_migration_files => true)
        puts "*** db:migrate:reset executed ***\n"
      end

      desc 'Perform migration up/down to VERSION.'
      task :to => [:connect] do
        version = ENV['VERSION'].to_i
        if version == 0
          puts "\nVERSION must be larger than 0. Use rake db:migrate:down to erase all data.\n"
          exit false
        end

        Sequel::Migrator.run(DB, ENV['MIGRATION_PATH'], :target => version, :allow_missing_migration_files => true)
        puts "*** db:migrate:to VERSION=[#{version}] executed ***\n"
      end

      desc 'Perform migration up to latest migration available.'
      task :up => [:connect] do
        Sequel::Migrator.run(DB, ENV['MIGRATION_PATH'], :allow_missing_migration_files => true)
        puts "*** db:migrate:up executed ***\n"
      end

      desc 'Perform migration down (erase all data).'
      task :down => [:connect] do
        Sequel::Migrator.run(DB, ENV['MIGRATION_PATH'], :target => 0, :allow_missing_migration_files => true)
        puts "*** db:migrate:down executed ***"
      end
 
      module Sequel
        class TimestampMigrator < Migrator
          def run
            migration_tuples.each do |m, f, direction|
              t = Time.now
              puts "#{f} \n\n"
              db.log_info("Begin applying migration #{f}, direction: #{direction}")
              checked_transaction(m) do
                m.apply(db, direction)
                fi = f.downcase
                direction == :up ? ds.insert(column=>fi) : ds.filter(column=>fi).delete
              end
              db.log_info("Finished applying migration #{f}, direction: #{direction}, took #{sprintf('%0.6f', Time.now - t)} seconds")
            end
            nil
          end

          def default_schema_table
            ENV['SCHEMA_TABLE'].to_sym
          end
        end
      end

    end
  end

