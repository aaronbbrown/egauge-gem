Sequel.migration do
  up do
    run "create index series_register_id_month_idx on series(register_id, date_part('month', time))"
  end

  down do
    alter_table(:series) do
      drop_index name: 'series_register_id_month_idx'
    end
  end
end
