class AddressController < ApplicationController
  def index
    @address = Address.new
  end

  def show
    id = params.extract_value(:id)
    @address = Address.find(id).first
    if @address
      forecast_for_address = ForecastService.call(@address)
      @address.current_forecast = forecast_for_address
    else
      flash[:alert] = "Address not found"
      redirect_to index
    end
    render template: "address/forecast"
  end

  def create
    @address = Address.find_or_create_by(address_params)
    respond_to do |format|
     if @address.save
        forecast_for_address = ForecastService.call(@address)
        @address.current_forecast = forecast_for_address
        format.turbo_stream { render turbo_stream: turbo_stream.update("forecast", partial: "forecast") }
     else
        format.html { render :index, status: :unprocessable_entity }
     end
    end
  end

  def forecast
    redirect_to @address
  end

  def show_forecast
    @address
  end

  private


    # Using a private method to encapsulate the permitted parameters is a good
    # pattern. You can use the same list for both create and update.
    def address_params
      params.expect(address: [ :state, :primary_line, :zip_code ])
    end
end
