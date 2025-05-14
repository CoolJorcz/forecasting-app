class Address < ApplicationRecord
  validates :zip_code, presence: true, format: { with: /\A\d{5}(-\d{4})?\z/,
    message: 'only 5 digit zips or zip+4s allowed (e.g. "100098" or "10098-2345")'
  }
  validates :state, presence: true, format: { with: /\A[a-zA-Z]{2}\z/,
    message: "only 2 letter states allowed" }
end
