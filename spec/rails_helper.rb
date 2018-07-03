# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'
require File.expand_path('../dummy/config/environment', __FILE__)
require 'rspec/rails'

Dir[File.expand_path('**/*.rb', './spec/support/')].each { |f| require f }
