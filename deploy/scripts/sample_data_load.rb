require_relative 'db_connection'
require 'bundler/setup'
require 'bundler'
require 'json'
require 'yaml'
require 'mysql2'
require 'sequel'
require 'tiny_tds'
require 'open3'


    def drop_fk
        ### Dropping table foreign keys
        puts "=================================================================\n\n"
        puts "Dropping Foreign keys before loading data ...\n\n"
        fks = []
        fks = db.fetch("SELECT TABLE_NAME, CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE REFERENCED_TABLE_SCHEMA = '#{$db}' GROUP BY TABLE_NAME, CONSTRAINT_NAME").all
        fks.each do |fk|
          db.run("ALTER TABLE #{fk[:TABLE_NAME]} DROP FOREIGN KEY #{fk[:CONSTRAINT_NAME]}")
        end
        puts "Done ...\n\n"
    end

    def remove_data
        ### Removing table by filename reverse order
        puts "=================================================================\n\n"
        $sample_data_file_reverse.each do |f|
            content = File.read(f)

            jcontent = JSON.parse(content)

            jcontent.each do |tbl,row|
                puts "Removing data from Table: #{tbl} ...\n\n"
                DB[Sequel[ENV['SRC_DB_SCHEMA'].to_sym][tbl.to_sym]].delete

            end
        end
        puts "Done ...\n\n"
    end

    def load_data
        ### Loading table by filename order
        puts "=================================================================\n\n"
        $sample_data_file.each do |f|
            content = File.read(f)

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
    #db = Sequel.connect('mysql2://chronos:chronos@hq-int-ppms-vdb01.laxino.local:3306/i2_ppms_dev1')

src_env = {
  'DB_ADAPTER' => 'tinytds',
  'DB_HOST' => ENV['SRC_DB_HOST'],
  'DB_NAME' => ENV['SRC_DB_NAME'],
  #'DB_USER' => ENV['SP_DB_USER'],
  #'DB_PASSWORD' => ENV['SP_DB_PASSWORD'],
  'DB_PORT' => ENV['SRC_DB_PORT']
}

DB = db_connection(src_env)

    $sample_data_path=ARGV[0]
    $sample_data_file = []
    $sample_data_file = Dir.glob("#{$sample_data_path}/*.json").sort
    $sample_data_file_reverse = Dir.glob("#{$sample_data_path}/*.json").sort.reverse
    $db = ENV['DB_NAME']

    #drop_fk    
    remove_data
    load_data
    puts "Done ...\n\n"

