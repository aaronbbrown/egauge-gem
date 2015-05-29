Sequel.migration do
  up do
    run "create index series_register_id_year_idx on series(register_id, date_part('year', time))"
  end

  down do
    alter_table(:series) do
      drop_index name: 'series_register_id_year_idx'
    end
  end
end
