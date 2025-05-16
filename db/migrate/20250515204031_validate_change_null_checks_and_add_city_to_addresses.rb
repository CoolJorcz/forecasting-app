class ValidateChangeNullChecksAndAddCityToAddresses < ActiveRecord::Migration[8.0]
  def up
    validate_check_constraint :addresses, name: "addresses_city_null"
    change_column_null :addresses, :city, false
    remove_check_constraint :addresses, name: "addresses_city_null"
  end

  def down
    add_check_constraint :addresses, "city IS NOT NULL", name: "addresses_city_null", validate: false
    change_column_null :addresses, :city, true
  end
end
