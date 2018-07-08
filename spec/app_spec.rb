require 'rack/test'
require 'pathname'

RSpec.describe App do
  include Rack::Test::Methods

  def app
    App
  end

  describe 'POST /users/:name/tweets' do
    context 'when the user does not exist' do
      it 'returns an error message' do
        post '/users/not_found/tweets'
        expect(last_response).to be_not_found
      end
    end

    context 'when the user exists' do
      before do
        User.register(
          name: 'Example User',
          username: 'example',
          access_token: 'token',
          access_token_secret: 'secret'
        )
      end

      STATUS_UPDATE_URL = 'https://api.twitter.com/1.1/statuses/update.json'.freeze

      let(:tweet) do
        Pathname.new(__FILE__).join('..', 'fixtures', 'tweet.json')
      end

      before do
        stub_request(:post, STATUS_UPDATE_URL).to_return(
          body: File.new(tweet),
          headers: { content_type: 'application/json; charset=utf-8' }
        )
      end

      it 'succeeds' do
        post '/users/example/tweets', 'This is my tweet text'
        expect(last_response.status).to be 201
      end

      it 'posts the tweet to Twitter' do
        post '/users/example/tweets', 'This is my tweet text'
        expect(a_request(:post, STATUS_UPDATE_URL).with(body: { status: 'This is my tweet text' })).to have_been_made
      end
    end
  end

  describe 'GET /auth/twitter' do
    context 'when the authentication is successful' do
      before do
        OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(
          provider: 'twitter',
          info: {
            nickname: 'jappleseed',
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

        session = last_request.env['rack.session']
        current_user = User[session[:user_id]]
        expect(current_user).to have_attributes(
          name: 'John Appleseed',
          username: 'jappleseed',
          access_token: 'foo',
          access_token_secret: 'bar'
        )
      end
    end
  end
end
