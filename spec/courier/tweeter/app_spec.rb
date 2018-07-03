require 'courier/tweeter/app'
require 'rack/test'

RSpec.describe Courier::Tweeter::App do
  include Rack::Test::Methods

  def app
    described_class
  end

  describe '/auth/twitter' do
    context 'when the authentication is successful' do
      before do
        OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(
          provider: 'twitter',
          info: {
            name: 'John Appleseed'
          },
          credentials: {
            token: 'foo',
            secret: 'bar'
          }
        )
      end

      after do
        OmniAuth.config.mock_auth[:twitter] = nil
      end

      it 'logs in to twitter' do
        get '/auth/twitter'
        follow_redirect!
        expect(last_response.body).to include 'Authenticated as John Appleseed'
        expect(last_response.body).to include 'Token: foo'
        expect(last_response.body).to include 'Secret: bar'
      end
    end
  end
end
