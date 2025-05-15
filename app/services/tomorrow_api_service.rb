class TomorrowApiService
  attr_reader :address

  #
  # <Description>
  #
  # @param [<Type>] address <description>
  #
  def initialize(address)
    @api_key = tomorrow_api_key
    @base_url = forecast_api
    @address = address
  end

  #
  # <Description>
  #
  # @return [<Type>] <description>
  #
  def forecast_api
    ENV["TOMORROW_BASE_URL"]
  end

  #
  # <Description>
  #
  # @return [<Type>] <description>
  #
  def query_params
    iso_3166_location_value = "US"
    measurement_units = "imperial"
    { location: "#{address.zip_code} #{iso_3166_location_value}", units: measurement_units, apikey: tomorrow_api_key }
  end

  #
  # <Description>
  #
  # @param [<Type>] response <description>
  #
  # @return [<Type>] <description>
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
