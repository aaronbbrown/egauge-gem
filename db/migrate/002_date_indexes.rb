Sequel.migration do
  up do
    run "CREATE INDEX \"series_date_part_date_part1_idx\" ON series(date_part('week'::text, \"time\"), date_part('hour'::text, \"time\"))"
  end

  down do
    alter_table(:series) do
      drop_index name: 'series_date_part_date_part1_idx'
    end
  end
end
