require 'rails_helper'

RSpec.describe "Addresses", type: :request do
  describe "GET /" do
    it 'renders the main page  template' do
      get '/'
      expect(response).to render_template(:index)
    end
  end

  describe "POST /forecast" do
    it 'retrieves the forecast for an address' do
     post '/address/forecast', params: { address: { primary_line: '20 W 34th St.', state: 'NY', zip_code: '10001' } }
     follow_redirect!

     expect(response).to render_template(:address_forecast)
    end
  end
end
