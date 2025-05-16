require 'rails_helper'

RSpec.describe ForecastService do
  # let(:mock_forecast) do
  #   {
  #     current_temperature: 60.9,
  #     current_time: "2025-05-14T20:45:00Z",
  #     feels_like: 60.9,
  #     location: {
  #       lat: 40.748477935791016,
  #       lon: -73.99413299560547,
  #       name: "Manhattan, New York County, City of New York, New York, 10001, United States",
  #       zip_code: "10001"
  #     },
  #     primary_line: "20 W 34th St."
  #   }
  # end
  #

  describe 'expected forecast' do
    def valid_time?(string)
      begin
        Time.parse(string)
        true
      rescue
        false
      end
    end

    def mock_forecast
      File.read('./spec/mocks/tomorrow_api_response.json')
    end
    # // 'https://api.tomorrow.io/v4/weather/realtime?location=10001%20US&units=imperial&apikey=CeMSaky78SbOJ2b3XjtpQw9pjMAFuLq6'
    def stub_api_request
      stub_request(:get, 'https://api.tomorrow.io/v4/weather/realtime').with(query: hash_including({
        'location' => '10001 US',
        'units' => 'imperial'
      })).to_return(status: 200, body: mock_forecast, headers: {})
    end

    before(:all) do
      address_to_process = create(:address)
      stub_api_request
      @forecast = ForecastService.call(address_to_process)
    end

    it 'gets the temperature for an address' do
      expect(@forecast[:current_temperature]).to be_a(Float)
    end

    it 'gets the time for the address' do
      expect(valid_time?(@forecast[:current_time])).to eq(true)
    end

    it 'returns a feels_like temperature' do
      expect(@forecast[:feels_like]).to be_a(Float)
    end

    it 'returns the location' do
      expect(@forecast.dig(:location, :name)).to be_a(String)
    end

    xit 'retrieves the forecast from a cache if it has been recently retrieved' do
    end

    xit 'calls the tomorrow.io forecast API if no forecast exists' do
    end
  end
end
