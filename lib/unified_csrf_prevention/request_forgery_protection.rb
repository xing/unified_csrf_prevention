# frozen_string_literal: true

require 'active_support/concern'

require 'unified_csrf_prevention/core'
require 'unified_csrf_prevention/middleware'

module UnifiedCsrfPrevention
  # ApplicationController concern implementing request authenticity validation
  # See https://github.com/xing/cross-application-csrf-prevention#application-action-filter
  module RequestForgeryProtection
    extend ActiveSupport::Concern

    class_methods do
      def protect_from_forgery(options = {})
        super
        prepend_before_action :setup_csrf_token
      end
    end

    private

    def valid_authenticity_token?(_session, token)
      valid_token?(token) || super
    end

    def compare_with_real_token(token, _session)
      valid_token?(token)
    end

    def real_csrf_token(_session)
      csrf_token
    end

    def setup_csrf_token
      csrf_token
    end

    def csrf_token
      @csrf_token ||= if valid_token?(existing_token) && token_of_correct_length?(existing_token)
        existing_token
      else
        new_token
      end
    end

    def new_token
      raise UnifiedCsrfPrevention::ConfigurationError, 'UnifiedCsrfPrevention::Middleware middleware must be used' unless Rails.configuration.middleware.include?(UnifiedCsrfPrevention::Middleware)
      request.env[Core::TOKEN_RACK_ENV_VAR] = Core.generate_token
    end

    def valid_token?(token)
      Core.valid_token?(token, checksum)
    end

    def existing_token
      request.cookies[Core::TOKEN_COOKIE_NAME]
    end

    def checksum
      request.cookies[Core::CHECKSUM_COOKIE_NAME]
    end

    def token_of_correct_length?(token)
       token.length == ActionController::RequestForgeryProtection::AUTHENTICITY_TOKEN_LENGTH
    end
  end
end
