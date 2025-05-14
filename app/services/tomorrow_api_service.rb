class TomorrowAPIService
  attr_reader :address

  def initialize(address)
    @api_key = tomorrow_api_key
    @base_url = forecast_api
    @address = address
  end

  def forecast_api
    "https://api.tomorrow.io/v4/weather/realtime"
  end

  def query_params
    iso_3166_location_value = "US"
    measurement_units = "imperial"
    { location: "#{address.zip_code} #{iso_3166_location_value}", units: measurement_units, apikey: tomorrow_api_key }
  end

  def extract_current_temperature(response)
    {
      current_time: response.dig("data", "time"),
      current_temperature: response.dig("data", "values", "temperature"),
      feels_like: response.dig("data", "values", "temperatureApparent"),
      location: {
        lat: response.dig("location", "lat"),
        lon: response.dig("location", "lon"),
        name: response.dig("location", "name"),
        zip_code: address.zip_code
      }
    }
  end

  private
    def tomorrow_api_key
      ENV["TOMORROW_API_KEY"]
    end
end
