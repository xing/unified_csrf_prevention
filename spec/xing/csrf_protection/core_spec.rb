# frozen_string_literal: true

require 'rails_helper'

describe UnifiedCsrfPrevention::Core do
  describe '#generate_token' do
    subject { described_class.generate_token }

    it { is_expected.to match(/\A[\w\-]+\z/) }
    it { expect(subject.length).to eq ActionController::RequestForgeryProtection::AUTHENTICITY_TOKEN_LENGTH }

    context 'randomness source' do
      let(:bytes) { double }
      let(:encoded_bytes) { double }
      let(:encoded_bytes_substring) { double }

      before do
        allow(SecureRandom).to receive(:random_bytes).and_return bytes
        allow(Base64).to receive(:urlsafe_encode64).with(bytes, anything).and_return encoded_bytes
        allow(encoded_bytes).to receive(:[]).and_return(encoded_bytes_substring)
      end

      it { is_expected.to be encoded_bytes_substring }
    end
  end

  describe '#checksum_for' do
    let(:token) { 'a token' }

    subject { described_class.checksum_for(token) }

    context 'when the configuration variable is not set' do
      before do
        allow(Rails.configuration).to receive(:unified_csrf_prevention_key).and_raise(NoMethodError)
      end

      it { expect { subject }.to raise_error UnifiedCsrfPrevention::ConfigurationError }
    end

    context 'when the configuration variable is set' do
      let(:shared_secret_key) { 'a shared secret key' }
      before do
        allow(Rails.configuration).to receive(:unified_csrf_prevention_key).and_return(shared_secret_key)
      end

      it { is_expected.to match(/\A[\w\-]+\z/) }

      context 'example from the specification' do
        let(:token) { 'such protect' }
        let(:shared_secret_key) { 'much secure' }

        it { is_expected.to eq 'fEFyEXot47K5knjFe7MB-CKW4q99a7BmP9rKwrxf9Qk' }
      end
    end
  end

  describe '#valid_token?' do
    let(:token) { double }
    let(:checksum) { double }

    subject { described_class.valid_token?(token, checksum) }

    context 'token is missing' do
      let(:token) {}

      it { is_expected.to be false }
    end

    context 'checksum is missing' do
      let(:checksum) {}

      it { is_expected.to be false }
    end

    context 'comparing checksums' do
      let(:computed_checksum) { double }

      before do
        allow(described_class).to receive(:checksum_for).with(token).and_return(computed_checksum)
        allow(ActiveSupport::SecurityUtils).to receive(:secure_compare).and_return(checksums_equal?)
      end

      after do
        expect(ActiveSupport::SecurityUtils).to have_received(:secure_compare).with(computed_checksum, checksum)
      end

      context 'invalid checksum' do
        let(:checksums_equal?) { false }

        it { is_expected.to be false }
      end

      context 'valid checksum' do
        let(:checksums_equal?) { true }

        it { is_expected.to be true }
      end
    end
  end
end
