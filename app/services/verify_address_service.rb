#
# <Description>
#
class VerifyAddressService
  require "lob"
  attr_reader :raw_address, :verified, :verified_address

  #
  # <Description>
  #
  # @param [<Type>] address <description>
  #
  def initialize(address)
    @raw_address = address
    @verified = false
    @verified_address = nil
  end

  #
  # <Description>
  #
  # @param [<Type>] address <description>
  #
  # @return [<Type>] <description>
  #
  def verify_address(address)
    config = Lob::Configuration.default
    config.username = api_key

    begin
      verification_api = Lob::UsVerificationsApi.new

      response = verification_api.verifySingle(
        recipient: "",
        primary_line: address[:primary_line],
        city: address[:city],
        state: address[:state],
        zip_code: address[:zip_code]
      )
      verified_components = response.components
      {
        primary_line: verified_components.primary_line,
        city: verified_components.city,
        state: verified_components.state,
        zip_code: verified_components.zip_code
      }
    rescue => e
      Rails.logger.error("Unable to verify address, returning address")
      address
    end
  end

  #
  # <Description>
  #
  # @param [<Type>] address <description>
  #
  # @return [<Type>] <description>
  #
  def self.call(address)
    verification_service = VerifyAddressService.new(address)
    @verified_address = verification_service.verify_address(address)
    @verified = true
    @verified_address
  end

  private
    def api_key
      ENV["LOB_API_KEY"]
    end
end
