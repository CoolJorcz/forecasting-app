module AddressHelper
  def call_forecast_service
    forecast_for_address = ForecastService.call(@address)
    @address.current_forecast = forecast_for_address
  end
end
