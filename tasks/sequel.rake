namespace :db do
    require 'bundler/setup'
    require 'bundler'
    require 'sequel'
    require 'yaml'
    require 'json'
    namespace :migrate do
      Sequel.extension :migration

      task :connect do
        DB = Sequel.connect( :adapter  => 'tinytds',
                             :host     => ENV['DB_HOST'],
                             :database => ENV['DB_DATABASE'],
                             :user     => ENV['DB_USER'],
                             :password => ENV['DB_PASSWORD'],
                             :port     => ENV['DB_PORT'],
                             :identifier_input_method => nil
                            )
      end

      desc 'Perform migration reset (full erase and migration up).'
      task :reset => [:connect] do
        Sequel::Migrator.run(DB, ENV['MIGRATION_PATH'], :target => 0, :allow_missing_migration_files => true)
        Sequel::Migrator.run(DB, ENV['MIGRATION_PATH'], :allow_missing_migration_files => true)
        puts '*** db:migrate:reset executed ***'
      end

      desc 'Perform migration up/down to VERSION.'
      task :to => [:connect] do
        version = ENV['VERSION'].to_i
        if version == 0
          puts 'VERSION must be larger than 0. Use rake db:migrate:down to erase all data.'
          exit false
        end

        Sequel::Migrator.run(DB, ENV['MIGRATION_PATH'], :target => version, :allow_missing_migration_files => true)
        puts "*** db:migrate:to VERSION=[#{version}] executed ***"
      end

      desc 'Perform migration up to latest migration available.'
      task :up => [:connect] do
        Sequel::Migrator.run(DB, ENV['MIGRATION_PATH'], :allow_missing_migration_files => true)
        puts '*** db:migrate:up executed ***'
      end

      desc 'Perform migration down (erase all data).'
      task :down => [:connect] do
        Sequel::Migrator.run(DB, ENV['MIGRATION_PATH'], :target => 0, :allow_missing_migration_files => true)
        puts '*** db:migrate:down executed ***'
      end
 
      module Sequel
        class TimestampMigrator < Migrator
          def run
            migration_tuples.each do |m, f, direction|
              t = Time.now
              puts '*' * 50
              puts f
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

