# frozen_string_literal: true

require 'unified_csrf_prevention/core'

module UnifiedCsrfPrevention
  # Rack middleware to set the token and checksum cookies
  # See https://github.com/xing/cross-application-csrf-prevention#token-generation
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      if env.key?(Core::TOKEN_RACK_ENV_VAR)
        token = env[Core::TOKEN_RACK_ENV_VAR]
        set_csrf_cookies!(headers, token)
        Rails.logger.info("Set CSRF token: #{token}")
      end

      [status, headers, body]
    end

    private

    def set_csrf_cookies!(headers, token)
      checksum = Core.checksum_for(token)

      set_cookie!(headers, Core::TOKEN_COOKIE_NAME, value: token)
      set_cookie!(headers, Core::CHECKSUM_COOKIE_NAME, value: checksum, httponly: true)
    end

    def set_cookie!(headers, name, data)
      cookie = {
        path: '/',
        secure: secure_cookies?,
        same_site: :strict,
      }.merge(data)

      Rack::Utils.set_cookie_header!(headers, name, cookie)
    end

    def secure_cookies?
      Rails.env.production? || Rails.env.preview?
    end
  end
end
