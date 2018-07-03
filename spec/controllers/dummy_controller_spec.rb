# frozen_string_literal: true

require 'rails_helper'

describe DummyController, type: :controller do
  let(:new_token) { 'This should be exactly 32 bytes.' }
  let(:short_token) { '😻' }

  before do
    ActionController::Base.allow_forgery_protection = true # RSpec unconditionally disallows the forgery protection in controller tests
    allow(UnifiedCsrfPrevention::Core).to receive(:generate_token).and_return(new_token)
  end

  describe '#index' do
    render_views

    let(:perform_request) do
      get :index
    end

    context 'when token and checksum cookies not sent' do
      let(:output_token) { new_token }

      it_behaves_like 'an action that outputs the csrf token'
      it_behaves_like 'an action that outputs the csrf cookies'
    end

    context 'when token and checksum cookies sent' do
      include_context 'with token and checksum'

      context 'with a valid token' do
        let(:valid_token?) { true }
        let(:output_token) { token }

        it_behaves_like 'an action that outputs the csrf token'
        it_behaves_like 'an action that does not output the csrf cookies'
      end

      context 'with a valid but short token' do
        let(:valid_token?) { true }
        let(:token) { short_token }
        let(:output_token) { new_token }

        it_behaves_like 'an action that outputs the csrf token'
        it_behaves_like 'an action that outputs the csrf cookies'
      end

      context 'with an invalid token' do
        let(:valid_token?) { false }
        let(:output_token) { new_token }

        it_behaves_like 'an action that outputs the csrf token'
        it_behaves_like 'an action that outputs the csrf cookies'
      end
    end

    context 'when cookies middleware is not installed' do
      before do
        allow(Rails.application.config.middleware).to receive(:include?).with(UnifiedCsrfPrevention::Middleware).and_return(false)
      end

      it 'raises a configuration error' do
        expect { perform_request }.to raise_error UnifiedCsrfPrevention::ConfigurationError
      end
    end
  end

  describe '#success' do
    let(:perform_request) do
      get :success
    end

    context 'when token and checksum cookies not sent' do
      let(:output_token) { new_token }

      it_behaves_like 'an action that outputs the csrf cookies'
    end

    context 'when token and checksum cookies sent' do
      include_context 'with token and checksum'

      context 'with a valid token' do
        let(:valid_token?) { true }
        let(:output_token) { token }

        it_behaves_like 'an action that does not output the csrf cookies'
      end

      context 'with an invalid token' do
        let(:valid_token?) { false }
        let(:output_token) { new_token }

        it_behaves_like 'an action that outputs the csrf cookies'
      end
    end
  end

  describe '#update' do
    context 'when token and checksum cookies not sent' do
      let(:output_token) { new_token }

      context 'request has no parameters' do
        include_context 'empty update request'

        it_behaves_like 'an action that responds with a csrf validation error'
        it_behaves_like 'an action that outputs the csrf cookies'
      end

      context 'request includes a csrf token form parameter' do
        let(:token) { 'some token out of nowhere' }
        include_context 'update request with a csrf token form parameter'

        it_behaves_like 'an action that responds with a csrf validation error'
        it_behaves_like 'an action that outputs the csrf cookies'
      end

      context 'request includes a csrf token header' do
        let(:token) { 'some token out of nowhere' }
        include_context 'update request with a csrf token header'

        it_behaves_like 'an action that responds with a csrf validation error'
        it_behaves_like 'an action that outputs the csrf cookies'
      end
    end

    context 'when token and checksum cookies sent' do
      include_context 'with token and checksum'

      context 'with a valid token' do
        let(:valid_token?) { true }

        context 'and token is of shorter length' do
          let(:token) { short_token }
          let(:output_token) { new_token }

          include_context 'update request with a csrf token header'

          it_behaves_like 'an action that responds with OK'
          it_behaves_like 'an action that outputs the csrf cookies'
        end

        context 'request has no parameters' do
          include_context 'empty update request'

          it_behaves_like 'an action that responds with a csrf validation error'
          it_behaves_like 'an action that does not output the csrf cookies'
        end

        context 'request includes a csrf token form parameter' do
          include_context 'update request with a csrf token form parameter'

          it_behaves_like 'an action that responds with OK'
          it_behaves_like 'an action that does not output the csrf cookies'
        end

        context 'request includes a csrf token form parameter which was generated on the backend' do
          include_context 'update request with a fetched csrf token form parameter'

          it_behaves_like 'an action that responds with OK'
          it_behaves_like 'an action that does not output the csrf cookies'
        end

        context 'request includes a csrf token header' do
          include_context 'update request with a csrf token header'

          it_behaves_like 'an action that responds with OK'
          it_behaves_like 'an action that does not output the csrf cookies'
        end
      end

      context 'with an invalid token' do
        let(:valid_token?) { false }
        let(:output_token) { new_token }

        context 'request has no parameters' do
          include_context 'empty update request'

          it_behaves_like 'an action that responds with a csrf validation error'
          it_behaves_like 'an action that outputs the csrf cookies'
        end

        context 'request includes a csrf form parameter' do
          include_context 'update request with a csrf token form parameter'

          it_behaves_like 'an action that responds with a csrf validation error'
          it_behaves_like 'an action that outputs the csrf cookies'
        end

        context 'request includes a csrf token header' do
          include_context 'update request with a csrf token header'

          it_behaves_like 'an action that responds with a csrf validation error'
          it_behaves_like 'an action that outputs the csrf cookies'
        end
      end
    end
  end

  describe 'on_load hook' do
    context 'is triggered twice' do
      before do
        ActiveSupport.run_load_hooks(:action_controller, ActionController::Base)
        ActiveSupport.run_load_hooks(:action_controller, ActionController::Base)
      end

      it 'includes RequestForgeryProtection only ones' do
        expect(ActionController::Base.included_modules.find_all { |m| m == UnifiedCsrfPrevention::RequestForgeryProtection }.length).to be 1
      end
    end
  end
end
