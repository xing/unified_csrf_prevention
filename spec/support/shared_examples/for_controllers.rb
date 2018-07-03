# frozen_string_literal: true

TOKEN_INPUT_REGEXP = %r{<input type="hidden" name="authenticity_token" value="([^"]+)" />}
TOKEN_META_REGEXP  = %r{<meta name="csrf-token" content="([^"]+)" />}

shared_examples 'an action that outputs the csrf token' do
  let(:real_form_token) do
    encoded_token = response.body.match(TOKEN_INPUT_REGEXP)[1]
    decode_token(encoded_token)
  end

  let(:real_meta_token) do
    encoded_token = response.body.match(TOKEN_META_REGEXP)[1]
    decode_token(encoded_token)
  end

  it 'renders form with a new token' do
    perform_request

    expect(response.body).to match(TOKEN_INPUT_REGEXP)
    expect(real_form_token).to eq(output_token)
  end

  it 'renders csrf meta tags with a new token' do
    perform_request

    expect(response.body).to match(%r{<meta name="csrf-param" content="authenticity_token" />})
    expect(response.body).to match(TOKEN_META_REGEXP)
    expect(real_meta_token).to eq(output_token)
  end
end

shared_examples 'an action that outputs the csrf cookies' do
  it 'sets the token for the middleware' do
    begin
      perform_request
    rescue ActionController::InvalidAuthenticityToken
      nil
    end

    expect(request.env).to include('unified_csrf_prevention.token' => output_token)
  end
end

shared_examples 'an action that does not output the csrf cookies' do
  it 'does not set the token for the middleware' do
    begin
      perform_request
    rescue ActionController::InvalidAuthenticityToken
      nil
    end

    expect(request.env).not_to include('unified_csrf_prevention.token')
  end
end

shared_examples 'an action that responds with a csrf validation error' do
  it do
    expect { perform_request }.to raise_error ActionController::InvalidAuthenticityToken
  end
end

shared_examples 'an action that responds with OK' do
  it do
    perform_request

    expect(response).to be_ok
  end
end

# Code parts were taken from ActionController::RequestForgeryProtection
def decode_token(encoded_masked_token)
  masked_token = Base64.strict_decode64(encoded_masked_token)
  one_time_pad = masked_token[0...ActionController::RequestForgeryProtection::AUTHENTICITY_TOKEN_LENGTH]
  encrypted_csrf_token = masked_token[ActionController::RequestForgeryProtection::AUTHENTICITY_TOKEN_LENGTH..-1]
  one_time_pad.bytes.zip(encrypted_csrf_token.bytes).map { |(c1, c2)| c1 ^ c2 }.pack('c*')
end
