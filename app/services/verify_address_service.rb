#
# <Description>
#
class VerifyAddressService
  require "lob"
  attr_reader :raw_address, :verified, :verified_address, :config

  class UnknownProviderError < StandardError
  end
  #
  # Initialization method for VerifyAddressService
  # @param address [Address] address instance
  # @param verification_config [Class] 3rd party verification provider, defaults to Lob
  # @return [VerifyAddressService] Instance of VerifyAddressService
  def initialize(address, verification_config = Lob::Configuration.default)
    @raw_address = address
    @config = verification_config
    @verified = false
    @verified_address = nil
  end

  #
  # Wrapper for Lob's US verification API
  # @return verified_address [Hash] hash of verified address values
  def lob_verify_address
    config.username = api_key
    begin
      verification_api = Lob::UsVerificationsApi.new

      response = verification_api.verifySingle(
        recipient: "",
        primary_line: raw_address.primary_line,
        city: raw_address.city,
        state: raw_address.state,
        zip_code: raw_address.zip_code
      )

      verified_components = response.components
      {
        primary_line: response.primary_line || verified_components.primary_line,
        city: verified_components.city,
        state: verified_components.state,
        zip_code: verified_components.zip_code
      }
    rescue => e
      # TODO: This behavior is incorrect.. will need to figure out what to do with addresses that are not verified or verifiable
      Rails.logger.error("Unable to verify address: #{response.error}")
      address.attributes.compact
    end
  end

  #
  # Router for different address verification providers
  # @return VerifyAddressService#lob_verify_address instance method
  # @return error [UnknownProviderError] returns error if provider not defined in configuration
  def verify_address
    if config.is_a?(Lob::Configuration)
      lob_verify_address
    else
      Rails.logger.error("Unknown provider for verification, exiting")
      raise UnknownProviderError, "Unknown provider for address verification"
    end
  end

  # VerifyAddressService.call
  # Call method and entrypoint to VerifyAddressService
  # Why do we need this method? Need a verified zip code in order to retrieve forecast information, and to protect against
  # various issues of user input
  # @param address [Address] instance of Address
  # @return verified_address [Hash] Hash of Verified Address values
  #
  def self.call(address)
    verification_service = VerifyAddressService.new(address)
    @verified_address = verification_service.verify_address
    @verified = true
    @verified_address
  end

  private
    def api_key
      ENV["LOB_API_KEY"]
    end
end
