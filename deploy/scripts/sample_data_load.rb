require 'bundler/setup'
require 'bundler'
require 'json'
require 'yaml'
require 'mysql2'
require 'sequel'
require 'tiny_tds'

    def drop_fk
        ### Dropping table foreign keys
        puts "=================================================================\n\n"
        puts "Dropping Foreign keys before loading data ...\n\n"
        fks = []
        fks = DB.fetch("SELECT TABLE_NAME, CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE REFERENCED_TABLE_SCHEMA = '#{$db}' GROUP BY TABLE_NAME, CONSTRAINT_NAME").all
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
                DB[Sequel[ENV['SRC_DB_SCHEMA'].to_sym][tbl.to_sym]].delete
                #DB[tbl.to_sym].delete
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

            sqlserver_set_identity_insert(jcontent, 'ON') if ENV['SRC_DB_ADAPTER'] == 'tinytds'

            jcontent.each do |tbl,row|
                puts "Loading data into Table: #{tbl} ...\n\n"
                row.each do |r|
                  r.each do |k, v|
                    if v.is_a?(::Hash)
                       r[k] = v.to_json
                    end
                  end
                  
                  DB[Sequel[ENV['SRC_DB_SCHEMA'].to_sym][tbl.to_sym]].insert(r)
                end
            end

            sqlserver_set_identity_insert(jcontent, 'OFF') if ENV['SRC_DB_ADAPTER'] == 'tinytds'
        end
    end

    def sqlserver_set_identity_insert(js, switch)
        js.each do |tbl, row|
          puts "SET IDENTITY_INSERT [#{ENV['SRC_DB_SCHEMA']}].[#{tbl}] #{switch}\n\n"
          DB.run("SET IDENTITY_INSERT [#{ENV['SRC_DB_SCHEMA']}].[#{tbl}] #{switch}")
        end
    end

### Main
    #DB = Sequel.connect('mysql2://chronos:chronos@hq-int-ppms-vdb01.laxino.local:3306/i2_ppms_dev1')

    #ENV.each do |key, value|
    #  if key.start_with?('SRC') 
    #  #if key.end_with?('LEVEL')
    #    puts "#{key}: #{value}"
    #  end
    #end

    DB = Sequel.connect(
      adapter: ENV['SRC_DB_ADAPTER'],
      host: ENV['SRC_DB_HOST'],
      database: ENV['SRC_DB_NAME'],
      user: ENV['SRC_DB_USER'],
      password: ENV['SRC_DB_PASSWORD'],
      port: ENV['SRC_DB_PORT']
    )
    DB.extension(:identifier_mangling)
    DB.identifier_input_method = DB.identifier_output_method = nil


    $sample_data_path=ARGV[0]
    $sample_data_file = []
    $sample_data_file = Dir.glob("#{$sample_data_path}/*.json").sort
    $sample_data_file_reverse = Dir.glob("#{$sample_data_path}/*.json").sort.reverse
    $db = ENV['DB_NAME']

    #drop_fk    
    remove_data
    load_data
    puts "Done ...\n\n"

