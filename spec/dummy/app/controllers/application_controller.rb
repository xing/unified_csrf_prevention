require 'unified_csrf_prevention'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end
