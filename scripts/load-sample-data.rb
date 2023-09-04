require 'bundler/setup'
require 'bundler'
require 'json'
require 'yaml'
require 'mysql2'
require 'sequel'

    def drop_fk
        ### Dropping table foreign key
        puts "=================================================================\n\n"
        puts "Dropping Foreign keys before loading data ...\n\n"
        fks = []
        fks = DB.fetch("SELECT TABLE_NAME, CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE REFERENCED_TABLE_SCHEMA = '#{$mysql_db}' GROUP BY TABLE_NAME, CONSTRAINT_NAME").all
        fks.each do |fk|
          DB.run("ALTER TABLE #{fk[:TABLE_NAME]} DROP FOREIGN KEY #{fk[:CONSTRAINT_NAME]}")
        end
        puts "Done ...\n\n"
    end

    def remove_data
        ### Removing table by filename reverse order
        puts "=================================================================\n\n"
        $sample_data_file_reverse.each do |f|
            content = File.read(f)
            #puts "\n"
            jcontent = JSON.parse(content)

            jcontent.each do |tbl,row|
                puts "Removing data from Table: #{tbl} ...\n\n"
                DB[tbl.to_sym].delete
            end
        end
        puts "Done ...\n\n"
    end

    def load_data
        ### Loading table by filename order
        puts "=================================================================\n\n"
        $sample_data_file.each do |f|
            content = File.read(f)
            #puts "\n"
            puts "Reading data from file #{f} ...\n\n"
            jcontent = JSON.parse(content)

            jcontent.each do |tbl,row|
                puts "Loading data into Table: #{tbl} ...\n\n"
                row.each do |r|
                  r.each do |k, v|
                    if v.is_a?(::Hash)
                       r[k] = v.to_json
                    end
                  end
                  DB[tbl.to_sym].insert(r)

                end
            end
        end
    end

### Main
    #DB = Sequel.connect('mysql2://chronos:chronos@hq-int-ppms-vdb01.laxino.local:3306/i2_ppms_dev1')
    DB = Sequel.connect( :adapter  => 'mysql2',
                         :host     => ENV['MYSQL_HOST'],
                         :database => ENV['MYSQL_DATABASE'],
                         :user     => ENV['MYSQL_USER'],
                         :password => ENV['MYSQL_PASSWORD'],
                         :port     => ENV['MYSQL_PORT'],
                         :fractional_seconds  => ENV['FRACTIONAL_SECONDS'] || 'true',
                         :encoding => ENV['ENCODING'] || 'utf8mb4'
                       )

    $sample_data_file = []
    $sample_data_file = Dir.glob("sample_data/#{ENV['IMAGE']}/#{ENV['DB_TARGET']}/*.json").sort
    $sample_data_file_reverse = Dir.glob("sample_data/#{ENV['IMAGE']}/#{ENV['DB_TARGET']}/*.json").sort.reverse
    $mysql_db = ENV['MYSQL_DATABASE']

    drop_fk    
    remove_data
    load_data
    puts "Done ...\n\n"

