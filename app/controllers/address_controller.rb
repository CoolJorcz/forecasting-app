class AddressController < ApplicationController
rescue_from ForecastService::ExternalApiError, with: :external_error_handling
  # GET /index
  # Main page of Forecasting App. Sends back an Address form and renders the address/index.html.erb template
  # @return ['index' template] New form for Address.new
  #
  def index
    @address = Address.new
  end


  # GET /address/:id
  # @param [Hash] params Parameters from request
  # Used for html responses to show forecast information after create
  # @return [Template] address/forecast return partial of address/forecast
  # @return [Alert] error if address not found, return error
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

  # GET /address/:create
  # @param address_params [ActionController::Parameters.permitted_params] Permitted Params from request
  # @param address_params [String] :city City for Address
  # @param address_params [String] :state City for Address
  # @param address_params [String] :zip_code City for Address
  # @param address_params [String] :primary_line City for Address
  # Create Action for Addresses, address verification prior to create, and forecast creation for a verified address
  # @return [Template] address/forecast If turbo_stream, return partial of address/forecast. If HTML, redirect to show action
  # @return [Alert] error if address not found, return error
  def create
    @address = Address.find_or_initialize_by(address_params)

    if @address.invalid?
      flash.now[:errors] = @address.errors.full_messages
      return respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("flash", partial: "flash_messages"), status: :unprocessable_entity }
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
        format.html { render address_index_path, status: :unprocessable_entity }
     end
    end
  end

  private

    def external_error_handling
      flash[:notice] = "We're having difficulty fetching your forecast. Please try again shortly."
      redirect_to address_index_path, status: :internal_server_error
    end

    # Using a private method to encapsulate the permitted parameters is a good
    # pattern. You can use the same list for both create and update.
    def address_params
      params.expect(address: [ :state, :primary_line, :zip_code, :city ])
    end
end
