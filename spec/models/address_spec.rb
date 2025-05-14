require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:subject) { create(:address) }

  it 'should not save without a state' do
    address = Address.new(primary_line: nil, zip_code: '92780')
    expect { address.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should not save without a zip' do
    address = Address.new(primary_line: '123 Real Street', zip_code: nil, state: 'CA')
    expect { address.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should validate the length and structure of the zip' do
    address = Address.new(primary_line: '123 Real Street', zip_code: '9278')
    expect { address.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'validates the format of a state' do
    address =  Address.new(primary_line: '123 Real Street', state: 'dslgj')
    expect { address.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
