Sequel.migration do
  up do
    run "create index series_date_time_idx on series(date(time))"
  end

  down do
    alter_table(:series) do
      drop_index name: 'series_date_time_idx'
    end
  end
end
