class AddressController < ApplicationController
  def index
  end

  def show
    id = params.extract_value(:id)
    @address = Address.find(:id)
  end

  def forecast
    address = Address.new(address_params)

    begin
      address = ForecastService.call(address)

      if @address.save
        redirect_to @address
      else
        render "No forecast found!"
      end
    rescue => e
      raise e
    end
  end

  private
    # Using a private method to encapsulate the permitted parameters is a good
    # pattern. You can use the same list for both create and update.
    def address_params
      params.expect(address: [ :state, :primary_line, :zip_code ])
    end
end
