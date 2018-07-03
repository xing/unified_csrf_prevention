# frozen_string_literal: true

require 'unified_csrf_prevention/version'
require 'unified_csrf_prevention/railtie'

module UnifiedCsrfPrevention
  class ConfigurationError < RuntimeError; end
end
