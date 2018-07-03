# frozen_string_literal: true

shared_examples 'a middleware that does not set any cookie' do
  it { is_expected.to be_ok }

  it 'does not output Set-Cookie header' do
    expect(subject.headers).not_to include('Set-Cookie')
  end
end

shared_examples 'a middleware that sets secure csrf cookies' do
  it { is_expected.to be_ok }
  it 'sets the csrf cookie headers' do
    expect(subject.headers).to include('Set-Cookie' => %r{^csrf_token=#{token}; path=/; secure; SameSite=Strict$})
    expect(subject.headers).to include('Set-Cookie' => %r{^csrf_checksum=#{checksum}; path=/; secure; HttpOnly; SameSite=Strict$})
  end
end

shared_examples 'a middleware that logs generated csrf token' do
  before { allow(Rails.logger).to receive(:info) }

  it { is_expected.to be_ok }
  it 'logs the token' do
    subject
    expect(Rails.logger).to have_received(:info).with("Set CSRF token: #{token}")
  end
end

shared_examples 'a middleware that sets insecure csrf cookies' do
  it { is_expected.to be_ok }
  it 'sets the csrf cookie headers' do
    expect(subject.headers).to include('Set-Cookie' => %r{^csrf_token=#{token}; path=/; SameSite=Strict$})
    expect(subject.headers).to include('Set-Cookie' => %r{^csrf_checksum=#{checksum}; path=/; HttpOnly; SameSite=Strict$})
  end
end
