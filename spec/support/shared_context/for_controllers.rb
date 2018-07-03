# frozen_string_literal: true

shared_context 'with token and checksum' do
  let(:token) { 'A token should be 32 bytes long.' }
  let(:checksum) { 'a checksum' }

  before do
    allow(UnifiedCsrfPrevention::Core).to receive(:valid_token?).and_return(false)
    allow(UnifiedCsrfPrevention::Core).to receive(:valid_token?).with(token, checksum).and_return(valid_token?)

    request.cookies['csrf_token'] = token
    request.cookies['csrf_checksum'] = checksum
  end
end

shared_context 'empty update request' do
  let(:perform_request) do
    post :update
  end
end

shared_context 'update request with a csrf token form parameter' do
  let(:perform_request) do
    post_with_params :update, params: { authenticity_token: token }
  end
end

shared_context 'update request with a fetched csrf token form parameter' do
  render_views

  let(:perform_request) do
    get :index
    actual_token = response.body.match(%r{<input type="hidden" name="authenticity_token" value="([^"]+)" />})[1]

    post_with_params :update, params: { authenticity_token: actual_token }
  end
end

shared_context 'update request with a csrf token header' do
  let(:perform_request) do
    request.headers['X-CSRF-Token'] = token
    post :update
  end
end

# rspec-rails `post` interface is different starting from Rails 5
# https://relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec#specify-managing-a-widget-with-rails-integration-methods

POST_RAILS_5 = Gem.loaded_specs['rails']&.version.to_s.to_i >= 5

def post_with_params(action, params:)
  post action, POST_RAILS_5 ? { params: params } : params
end
