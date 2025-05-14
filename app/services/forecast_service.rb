class ForecastService
  require "httpx"
  require_relative "tomorrow_api_service"

  attr_reader :address, :provider

  def initialize(address, provider: TomorrowAPIService)
    @address = address
    @provider = provider.new(address)
    @current_forecast = {}
  end

  def fetch_forecast
    query_params = provider.query_params
    begin
      response = HTTPX.get(provider.forecast_api, params: query_params)

      if response.status == 200
        tomorrow_forecast = JSON.parse(response.body)
        forecast = provider.extract_current_temperature(tomorrow_forecast)
        forecast[:id] = address.id
        forecast[:primary_line] = address.primary_line
        forecast
      else
        raise response.body.to_s
      end
    rescue => e
      raise e
    end
  end


  # returns hash
  def self.call(address)
    found_address = Address.find_by(primary_line: address.primary_line) || Address.find_by(zip_code: address.zip_code)

    if found_address
      # move on to forecast retrieval
      Rails.cache.fetch([ address.zip_code, :fetch_forecast ], expires_in: 30.minutes) do
        forecast_service = ForecastService.new(address)
        forecast_service.fetch_forecast
      end
    else
      # Call Lob's US verification API, create new address, call forecast API
      address_instance = Address.create(address)
      forecast_service = ForecastService.new(address_instance)
      forecast_service.fetch_forecast
    end
  end

  private
    def tomorrow_api_key
      ENV["TOMORROW_API_KEY"]
    end
end
