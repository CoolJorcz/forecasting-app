class ForecastService
  require "httpx"
  require_relative "tomorrow_api_service"

  attr_reader :address, :provider

  #
  # <Description>
  #
  # @param [<Type>] address <description>
  # @param [<Type>] provider <description>
  #
  def initialize(address, provider: TomorrowApiService)
    @address = address
    @provider = provider.new(address)
    @current_forecast = {}
  end

  #
  # <Description>
  #
  # @return [<Type>] <description>
  #
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


  #
  # <Description>
  #
  # @param [<Type>] address <description>
  #
  # @return [Hash] Hash of Address values
  #
  def self.call(address)
    if address
      # move on to forecast retrieval
      Rails.cache.fetch([ address.zip_code, :fetch_forecast ], expires_in: 30.minutes) do
        Rails.logger.info("Cache miss, calling Forecast API")
        address.cache_miss = true
        forecast_service = ForecastService.new(address)
        forecast = forecast_service.fetch_forecast
        forecast[:set_at] = Time.zone.now
        forecast
      end
    else
      Rails.error("Address unknown")
    end
  end

  private
    def tomorrow_api_key
      ENV["TOMORROW_API_KEY"]
    end
end
