class AddressController < ApplicationController
  before_action :check_params
  skip_before_action :check_params, only: [ :index ]
  #
  # <Description>
  # GET /index
  # @return ['index' template] New form for Address.new
  #
  def index
    @address = Address.new
  end

  #
  # <Description>
  #
  # @return [<Type>] <description>
  #
  def show
    id = params.extract_value(:id)
    @address = Address.find(id).first
    if @address
      @address.call_forecast_service
    else
      flash[:alert] = "Address not found"
      redirect_to index
    end
    render template: "address/forecast"
  end

  #
  # <Description>
  #
  # @return [<Type>] <description>
  #
  def create
    @address = Address.find_by(address_params)

    if @address
      @address.call_forecast_service
    else
      # verify address, then call ForecastService
      verified_address = VerifyAddressService.call(address_params)
      @address = Address.create(verified_address)
      if @address.save
        @address.call_forecast_service
      end
    end

    respond_to do |format|
     if @address
        format.turbo_stream { render turbo_stream: turbo_stream.update("forecast", partial: "forecast") }
        format.html { redirect_to(@address) }
     else
        flash[:alert] = "Address not found"
        format.html { render :index, status: :unprocessable_entity }
     end
    end
  end

  private
    def check_params
      if !address_params
        flash[:error] = "Must provide address fields to check forecast!"
        redirect_to "/"
      end
    end

    # Using a private method to encapsulate the permitted parameters is a good
    # pattern. You can use the same list for both create and update.
    def address_params
      params.expect(address: [ :state, :primary_line, :zip_code, :city ])
    end
end
