class AddressController < ApplicationController
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
    @address = Address.find_or_initialize_by(address_params)

    if @address.invalid?
      flash[:errors] = @address.errors.messages
      return respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("flash_messages", partial: "flash_messages") }
        format.html { redirect_to address_index_path }
      end
    end

    if @address.id
      @address.call_forecast_service
    else
      # verify address, then call ForecastService
      verified_address = VerifyAddressService.call(@address)
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
        format.html { render "address/index", status: :unprocessable_entity }
     end
    end
  end

  private

    # Using a private method to encapsulate the permitted parameters is a good
    # pattern. You can use the same list for both create and update.
    def address_params
      params.expect(address: [ :state, :primary_line, :zip_code, :city ])
    end
end
