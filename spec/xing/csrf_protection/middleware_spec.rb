# frozen_string_literal: true

require 'rack'

describe UnifiedCsrfPrevention::Middleware do
  let(:app) do
    proc do |env|
      env['unified_csrf_prevention.token'] = token unless token.nil?
      [200, {}, 'some body']
    end
  end
  let(:middleware) { described_class.new(app) }
  let(:request) { Rack::MockRequest.new(middleware) }

  subject { request.get('/what-ever') }

  context 'when the application did not set the token' do
    let(:token) {}

    it_behaves_like 'a middleware that does not set any cookie'
  end

  context 'when the application set the token' do
    let(:token) { 'token' }
    let(:checksum) { 'some_checksum' }

    before do
      allow(UnifiedCsrfPrevention::Core).to receive(:checksum_for).with(token).and_return(checksum)
    end

    %w[production preview].each do |environment|
      context "in #{environment} environment" do
        before { allow(Rails.env).to receive(:"#{environment}?").and_return(true) }

        it_behaves_like 'a middleware that sets secure csrf cookies'
        it_behaves_like 'a middleware that logs generated csrf token'
      end
    end

    context 'in some other environment' do
      it_behaves_like 'a middleware that sets insecure csrf cookies'
    end
  end
end
