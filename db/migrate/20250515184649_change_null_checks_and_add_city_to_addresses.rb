class ChangeNullChecksAndAddCityToAddresses < ActiveRecord::Migration[8.0]
  def change
    add_column :addresses, :city, :string, null: false, default: 'PLACEHOLDER'
    add_check_constraint :addresses, "city IS NOT NULL", name: "addresses_city_null", validate: false
  end
end
