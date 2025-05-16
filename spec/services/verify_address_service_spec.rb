require 'rails_helper'

RSpec.describe VerifyAddressService do
  def valid_time?(string)
    begin
      Time.parse(string)
      true
    rescue
      false
    end
  end
  let(:address) { build(:address, {
    primary_line: '500 W Chicago Ave.',
    city: 'Chicago',
    state: 'IL',
    zip_code: '60601'
  }) }

  let!(:mock_lob_request) do
    struct = Struct.new(:components, :primary_line)
    component_struct = Struct.new(:city, :state, :zip_code, :primary_line)
    struct.new(component_struct.new('CHICAGO', 'IL', '60654', ''), '500 W CHICAGO AVE.')
  end

  before do
    allow_any_instance_of(Lob::UsVerificationsApi).to receive(:verifySingle).and_return(mock_lob_request)
  end

  describe 'a verified and doctored address by USPS standards' do
    before do
      @verified_address = VerifyAddressService.call(address)
    end

    it 'has a city' do
      expect(@verified_address[:city]).to eq(mock_lob_request.components.city)
    end

    it 'has a state' do
      expect(@verified_address[:state]).to eq(mock_lob_request.components.state)
    end


    it 'has a zip code' do
      expect(@verified_address[:zip_code]).to eq(mock_lob_request.components.zip_code)
    end

    it 'has a primary line' do
      expect(@verified_address[:primary_line]).to eq(mock_lob_request.primary_line)
    end
  end
end
