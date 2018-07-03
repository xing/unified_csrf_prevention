# frozen_string_literal: true

require 'rails/railtie'

require 'unified_csrf_prevention/middleware'
require 'unified_csrf_prevention/request_forgery_protection'

module UnifiedCsrfPrevention
  # A Railtie to automagically set up the gem's middleware and include
  # the controller concern when the gem is loaded
  class Railtie < Rails::Railtie
    initializer :unified_csrf_prevention_middleware do |app|
      app.middleware.use UnifiedCsrfPrevention::Middleware
    end

    initializer :unified_csrf_prevention_concern do
      ActiveSupport.on_load :action_controller do
        include UnifiedCsrfPrevention::RequestForgeryProtection
      end
    end
  end
end
