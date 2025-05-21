class ForecastService
  require "httpx"
  require_relative "tomorrow_api_service"

  attr_reader :address, :provider

  class ExternalApiError < StandardError
  end
  #
  # Initialization method for Forecast Service
  # @param [Address] address instance
  # @param provider [Class] Api Service provider dependency injected, defaults to TomorrowApiService
  # @return [ForecastService] Instance of ForecastService
  def initialize(address, provider: TomorrowApiService)
    @address = address
    @provider = provider.new(address)
    @current_forecast = {}
  end

  #
  # HTTP Wrapper for Forecast retrieval
  #
  # @return [Hash] forecast Forecast Hash from response body, plus the address id and the initial primary line provided for visibility
  # @example {
  #     current_temperature: 60.9,
  #     current_time: "2025-05-14T20:45:00Z",
  #     feels_like: 60.9,
  #     location: {
  #       lat: 40.748477935791016,
  #       lon: -73.99413299560547,
  #       name: "Manhattan, New York County, City of New York, New York, 10001, United States",
  #       zip_code: "10001"
  #     },
  #     set_at: 2025-05-14T20:45:00Z,
  #     primary_line: "20 W 34th St."
  #   }
  def fetch_forecast(retries: 0)
    query_params = provider.query_params
    begin
      raise ExternalApiError, "Undefined Provider Url!" if provider.forecast_api.nil?

      response = HTTPX.get(provider.forecast_api, params: query_params)
      case response
      in { status: (200..299) }
        tomorrow_forecast = JSON.parse(response.body)
        forecast = provider.extract_current_temperature(tomorrow_forecast)
        forecast[:id] = address.id
        forecast[:primary_line] = address.primary_line
        forecast
      in { status: (400..499) }
        Rails.logger.error(response.error)
        raise ExternalApiError, response.error
      in { error: error }
        if retries < 3
          retries += 1
          fetch_forecast(retries)
        else
          raise error, "Unable to reach Forecast API"
        end
      end
    rescue => e
      raise ExternalApiError, "Unable to fetch Forecast"
    end
  end


  #
  # Call method and entrypoint to ForecastService
  # Will retrieve from cache by zip code if set in previous 30 minutes. Otherwise, will call Forecast API provider.
  # @param [Address] address instance of Address
  # @return [Address#cache_miss] Virtual Attribute to determine the cache result
  # @return [Hash] forecast Hash of Forecast values
  # @example {
  #     current_temperature: 60.9,
  #     current_time: "2025-05-14T20:45:00Z",
  #     feels_like: 60.9,
  #     location: {
  #       lat: 40.748477935791016,
  #       lon: -73.99413299560547,
  #       name: "Manhattan, New York County, City of New York, New York, 10001, United States",
  #       zip_code: "10001"
  #     },
  #     set_at: 2025-05-14T20:45:00Z,
  #     primary_line: "20 W 34th St."
  #   }
  #
  def self.call(address)
    if address
      # move on to forecast retrieval
      Rails.cache.fetch([ address.zip_code, :fetch_forecast ], expires_in: (30.minutes.from_now - Time.current).round.seconds, race_condition_ttl: 10.seconds) do
        Rails.logger.info("Cache miss, calling Forecast API")
        address.cache_miss = true # determiner for whether a result is cached or not
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
