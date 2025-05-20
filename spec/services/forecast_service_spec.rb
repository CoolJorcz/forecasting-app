require 'rails_helper'

RSpec.describe ForecastService do
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
    def stub_api_request
      stub_request(:get, 'https://api.tomorrow.io/v4/weather/realtime').with(query: hash_including({
        'location' => '10001 US',
        'units' => 'imperial'
      })).to_return(status: 200, body: mock_forecast, headers: {})
    end

    def address_to_process
      address_to_process ||= create(:address)
    end

    before(:all) do
      stub_api_request
      @forecast = ForecastService.call(address_to_process)
    end

    after(:all) do
      Rails.cache.clear
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

    describe 'cache', type: :integration do
      let(:cached_forecast) { Rails.cache.read([ address_to_process.zip_code, :fetch_forecast ]) }
      before do
        allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::RedisCacheStore.new(url: ENV['REDIS_URL']))
        stub_api_request
      end

      it 'writes to Rails.cache for forecast information' do
        expect(cached_forecast[:current_time]).to eq(@forecast[:current_time])
      end

      it 'retrieves the forecast from a cache if it has been recently retrieved' do
        new_forecast = ForecastService.call(address_to_process)
        expect(new_forecast[:set_at]).to eq(cached_forecast[:set_at])
      end

      context 'expired cache' do
        let(:former_forecast) { ForecastService.call(address_to_process) }
        before do
          Rails.cache.clear
          travel_to 32.minutes.from_now
        end

        after do
          travel_back
        end

        it 'expires cached response after 30 minutes and fetches new' do
          former_forecast = @forecast.clone
          new_forecast = ForecastService.call(address_to_process)
          cached_forecast_time = former_forecast.dig(:set_at)
          new_forecast_time = new_forecast[:set_at]
          expect(new_forecast_time > cached_forecast_time).to eq(true)
        end
      end
    end
  end
end
