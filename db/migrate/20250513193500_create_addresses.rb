class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
    create_table :addresses, id: :uuid do |t|
      t.string "primary_line"
      t.string "zip_code", null: false
      t.string "state", null: false
      t.timestamps
    end
  end
end
