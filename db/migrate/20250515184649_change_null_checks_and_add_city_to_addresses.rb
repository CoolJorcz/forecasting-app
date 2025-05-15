class ChangeNullChecksAndAddCityToAddresses < ActiveRecord::Migration[8.0]
  def change
    add_column :addresses, :city, :string
    add_check_constraint :addresses, "city IS NOT NULL", name: "addresses_city_null", validate: false
    add_check_constraint :addresses, "primary_line IS NOT NULL", name: "addresses_primary_line_null", validate: false
    safety_assured do
      execute 'ALTER TABLE "addresses" VALIDATE CONSTRAINT "addresses_primary_line_null"'
    end

    change_column_null :addresses, :city, false, 'NULL PLACEHOLDER'
    change_column_null :addresses, :primary_line, false, 'NULL PLACEHOLDER'

    safety_assured do
      execute 'ALTER TABLE "addresses" DROP CONSTRAINT "addresses_primary_line_null"'
    end
  end
end
