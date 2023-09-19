require 'sequel'

def dbschema(table_name)
  Sequel[ENV['DB_SCHEMA'].to_sym][table_name]
end

namespace :db do
    require 'bundler/setup'
    require 'bundler'
    #require 'sequel'
    require 'yaml'
    require 'json'
    require 'tiny_tds'
    namespace :migrate do
      Sequel.extension :migration

      task :connect do
        case ENV['DB_ADAPTER']
        when 'mysql2'
          DB = Sequel.connect(
            adapter: 'mysql2',
            host: ENV['DB_HOST'],
            database: ENV['DB_NAME'],
            user: ENV['DB_USER'],
            password: ENV['DB_PASSWORD'],
            port: ENV['DB_PORT'],
            fractional_seconds: ENV['FRACTIONAL_SECONDS'] == "" ? 'true' : ENV['FRACTIONAL_SECONDS'],
            encoding: ENV['ENCODING'] == "" ? 'utf8mb4' : ENV['ENCODING']
          )
        when 'tinytds'
          DB = Sequel.connect(
            adapter: 'tinytds',
            host: ENV['DB_HOST'],
            database: ENV['DB_NAME'],
            user: ENV['DB_USER'],
            password: ENV['DB_PASSWORD'],
            port: ENV['DB_PORT']
          )
          DB.extension(:identifier_mangling)
          DB.identifier_input_method = DB.identifier_output_method = nil
          #puts DB.inspect
          #puts DB.methods

        else
          raise "Unsupported adapter: #{ENV['DB_ADAPTER']}"
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

