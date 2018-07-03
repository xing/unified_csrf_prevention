# frozen_string_literal: true

require 'base64'
require 'openssl'
require 'securerandom'

require 'rails'
require 'active_support/security_utils'

module UnifiedCsrfPrevention
  # Low-level routines and constants
  # See https://github.com/xing/cross-application-csrf-prevention#low-level-implementation-details
  module Core
    TOKEN_COOKIE_NAME = 'csrf_token'
    CHECKSUM_COOKIE_NAME = 'csrf_checksum'
    TOKEN_RACK_ENV_VAR = 'unified_csrf_prevention.token'

    class << self
      def generate_token
        random_bytes_needed = (ActionController::Base::AUTHENTICITY_TOKEN_LENGTH * 0.75).ceil # Base 64 requires four bytes to store three bytes of data
        random_bytes = SecureRandom.random_bytes(random_bytes_needed)
        encode(random_bytes)[0...ActionController::Base::AUTHENTICITY_TOKEN_LENGTH]
      end

      def checksum_for(token)
        digest_algorithm = OpenSSL::Digest::SHA256.new
        token_digest = OpenSSL::HMAC.digest(digest_algorithm, shared_secret_key, token)
        encode(token_digest)
      end

      def valid_token?(token, checksum)
        !token.nil? && !checksum.nil? && ActiveSupport::SecurityUtils.secure_compare(checksum_for(token), checksum)
      end

      private

      def shared_secret_key
        Rails.configuration.unified_csrf_prevention_key
      rescue NoMethodError
        raise UnifiedCsrfPrevention::ConfigurationError, 'Configuration setting `unified_csrf_prevention_key` is not defined'
      end

      def encode(binary_string)
        Base64.urlsafe_encode64(binary_string, padding: false)
      end
    end
  end
end
