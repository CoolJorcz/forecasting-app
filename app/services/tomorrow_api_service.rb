class TomorrowApiService
  attr_reader :address

  #
  # Initialization method for the TomorrowApiService
  #
  # @param [Address] address an Address instance
  #
  def initialize(address)
    @api_key = tomorrow_api_key
    @base_url = forecast_api
    @address = address
  end

  #
  # Tomorrow.io's Real Time Forecast API url
  # @return url [String] base url for Tomorrow API's RealTime Forecast API
  #
  def forecast_api
    ENV["TOMORROW_BASE_URL"]
  end

  #
  # Query Params for the RealTime Forecast API. Using zip code for forecast and imperial for units
  # @return query_params [Hash] query params hash of location, measurement units, and the api_key
  #
  def query_params
    iso_3166_location_value = "US"
    measurement_units = "imperial" # metric also an option
    { location: "#{address.zip_code} #{iso_3166_location_value}", units: measurement_units, apikey: tomorrow_api_key }
  end

  #
  # From response, extraction of various values including
  # current_time: time in which the forecast request was made
  # current_temperature: temperature for current forecast
  # feels_like: what the apparent temperature is
  # location hash: including latitude, longitude and full name description of the area (ex. "Lower Peters Canyon, Irvine, Orange County, California, 92602, United States")
  # @param [Hash] response hash converted from JSON response body
  #
  # @return [Hash] forecast hash of extracted values
  #
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
