require 'rails_helper'

RSpec.describe "Addresses", type: :request do
  describe "GET /" do
    it 'renders the main page  template' do
      get '/'
      expect(response).to render_template(:index)
    end
  end
end
