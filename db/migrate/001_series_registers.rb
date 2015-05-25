Sequel.migration do
  up do
    create_table(:registers) do
      primary_key :id
      String :name, index: true, unique: true
    end

    create_table(:series) do
      foreign_key :register_id, :registers, null: false, index: true
      primary_key :id
      DateTime :time, index: true
      BigDecimal :watt_hours, size: [10,2]
      Integer :joules
      index [:time, :register_id], unique: true
    end
  end

  down do
    drop_table :series
    drop_table :registers
  end
end
