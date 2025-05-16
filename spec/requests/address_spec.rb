require 'rails_helper'

RSpec.describe "Addresses", type: :request do
  let(:verified_address) do
    {
      primary_line: '20 W 34th ST.',
      state: 'NY',
      city: 'NEW YORK',
      zip_code: '10001'
    }
  end

  let(:mock_forecast) do
    {
      current_time: "2025-05-16T07:41:00Z",
      current_temperature: 58.7,
      feels_like: 58.7,
      location:
        {
          lat: 33.735206604003906,
          lon: -117.7651596069336,
        name: "Lower Peters Canyon, Irvine, Orange County, California, 92602, United States",
        zip_code: "92602" },
      primary_line: "43 Carpenteria",
      set_at: "2025-05-16 07:41:22.964612000 UTC +00:00"
  }
  end

  before do
    allow(VerifyAddressService).to receive(:call).and_return(verified_address)
    allow(ForecastService).to receive(:call).and_return(mock_forecast)
  end

  describe "GET /" do
    it 'renders the main page  template' do
      get '/'
      expect(response).to render_template(:index)
    end
  end

  describe "POST /address/" do
    it 'retrieves the forecast for an address' do
      post '/address/', params: { address: { primary_line: '20 W 34th St.', state: 'NY', zip_code: '10001', city: 'New York' } }
      address = Address.find_by(primary_line: '20 W 34th St.', state: 'NY', zip_code: '10001', city: 'New York')
      expect(response).to redirect_to(address)
    end

    it 'redirects to index if no params are provided' do
      post '/address/', params: { address: { primary_line: '', state: '', zip_code: '', city: '' } }
      follow_redirect!
      expect(response).to render_template(:index)
    end

    describe 'valid addresses' do
      it 'creates an address if address does not exist' do
        address_not_found = Address.find_by(primary_line: '18 W 34th St.', state: 'NY', zip_code: '10001', city: 'New York')
        expect(address_not_found).to eq(nil)
        post '/address/', params: { address: { primary_line: '20 W 34th St.', state: 'NY', zip_code: '10001', city: 'New York' } }
        address = Address.find_by(primary_line: '20 W 34th St.', state: 'NY', zip_code: '10001', city: 'New York')
        expect(address).to be_a(Address)
      end
    end



    describe 'turbo streams', pending: 'Limitations in documentation on how to enact turbo stream testing due to formats absence' do
      it 'renders flash messages on error' do
        post '/address/', params: { address: { primary_line: '', state: '', zip_code: '', city: '' } }
        expect(response).to render_template(partial: '_flash_messages')
      end

      it 'renders forecast on success' do
        post '/address/', params: { address: { primary_line: '20 W 34th St.', state: 'NY', zip_code: '10001', city: 'New York' } }
        expect(response).to render_template(partial: '_forecast')
      end
    end
  end
end
