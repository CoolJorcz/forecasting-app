require 'rails_helper'

RSpec.describe "Addresses", type: :request do
  describe "GET /" do
    it 'renders the main page  template' do
      get '/'
      expect(response).to render_template(:index)
    end
  end

  describe "POST /create" do
    it 'retrieves the forecast for an address', pending: 'Issues with testing turbostreams due to format seemingly being deprecated' do
     post '/address/create', params: { address: { primary_line: '20 W 34th St.', state: 'NY', zip_code: '10001' } }
     expect(response).to render_template(partial: '_forecast')
    end
  end
end
