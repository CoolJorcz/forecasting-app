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
      tomorrow_forecast = JSON.parse(response.body)
      forecast = provider.extract_current_temperature(tomorrow_forecast)
      forecast[:id] = address.id
      forecast[:primary_line] = address.primary_line
      forecast
    rescue => e

    end
  end

  def self.call(address)
    forecast_service = ForecastService.new(address)
    address = Address.find_by(primary_line: address.primary_line) || Address.find_by(zip_code: address.zip_code)

    if address
      # move on to forecast retrieval
      forecast_service.fetch_forecast
    else
      # Call Lob's US verification API, create new address, call forecast API
    end
  end

  private
    def tomorrow_api_key
      ENV["TOMORROW_API_KEY"]
    end
end
