class AddressController < ApplicationController
  def index
    @address = Address.new
  end

  def show
    id = params.extract_value(:id)
    @address = Address.find(:id)
  end

  def forecast
    @address = Address.new(address_params)

    begin
      forecast_for_address = ForecastService.call(@address)

      @address.current_forecast = forecast_for_address
      redirect_to current_forecast
    rescue => e
      raise e
    end
  end

  def current_forecast
    @forecast_for_address = @address.current_forecast
    render "forecast"
  end

  private
    # Using a private method to encapsulate the permitted parameters is a good
    # pattern. You can use the same list for both create and update.
    def address_params
      params.expect(address: [ :state, :primary_line, :zip_code ])
    end
end
