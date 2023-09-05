Sequel.migration do
  up do
    create_table(:dim_dates) do
      primary_key :id, type: 'INT'
      Date :day_name, null: true
      Integer :day_of_week, null: true
      String :day_name_of_week, size: 50, null: true
      Integer :day_of_month, null: true
      Integer :day_of_year, null: true
      Integer :week_of_year, null: true
      String :month_name, size: 50, null: true
      Integer :month_of_year, null: true
      Integer :quarter_of_year, null: true
      String :quarter_name, size: 50, null: true
      Integer :day_key, null: true
      Integer :week_key, null: true
      Integer :month_key, null: true
      Integer :year_key, null: true
      Integer :quarter_key, null: true
      Integer :day_of_fiscal_year, null: true
      Integer :week_of_fiscal_year, null: true
      Integer :month_of_fiscal_year, null: true
      Integer :quarter_of_fiscal_year, null: true

    end

    alter_table(:dim_dates) do
      add_index [:day_name], name: 'IDX_dim_dates_day_name'
      add_index [:day_key], name: 'IDX_dim_dates_day_key'
      add_index [:week_key], name: 'IDX_dim_dates_week_key'
      add_index [:month_key], name: 'IDX_dim_dates_month_key'
      add_index [:year_key], name: 'IDX_dim_dates_year_key'
    end

  end

  down do
    drop_table(:dim_dates)
  end
end
