FactoryBot.define do
  factory :address do
    primary_line { '20 W 34th St.' }
    zip_code { '10001' }
    state { 'NY' }
    city { 'New York' }
  end
end
