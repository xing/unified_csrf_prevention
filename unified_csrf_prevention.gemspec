# frozen_string_literal: true

require 'English'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unified_csrf_prevention/version'

Gem::Specification.new do |s|
  s.name          = 'unified_csrf_prevention'
  s.version       = UnifiedCsrfPrevention::VERSION
  s.authors       = ['Egor Balyshev']
  s.email         = ['egor.balyshev@gmail.com']
  s.summary       = 'Cross-application CSRF prevention for Rails'
  s.description   = 'Unified stateless cross-application CSRF prevention implementation for Rails'
  s.homepage      = 'https://github.com/xing/unified_csrf_prevention'
  s.license       = 'MIT'

  s.required_rubygems_version = '>= 2.0'

  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_runtime_dependency 'rails', '>= 4.2'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'bundler', '~> 1.12'
  s.add_development_dependency 'rubocop', '~> 0.49.1'
  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'rspec-rails', '~> 3.6'
  s.add_development_dependency 'rake', '~> 12.0'
end
