RSpec.describe TweetsController do
  include ControllerSpec

  describe 'POST /users/:name/tweets' do
    context 'when the client is not logged in' do
      it 'returns an unauthorized response' do
        post '/users/not_found/tweets'
        expect(last_response.status).to be 401
      end
    end

    context 'when the user does not exist' do
      before do
        jwt sub: 'courier-posts', roles: ['service']
      end

      it 'returns an error message' do
        post '/users/not_found/tweets'
        expect(last_response).to be_not_found
      end
    end

    context 'when the user exists' do
      STATUS_UPDATE_URL = 'https://api.twitter.com/1.1/statuses/update.json'.freeze

      let(:tweet) { Pathname.new(__dir__).join('..', 'fixtures', 'tweet.json') }

      before do
        User.register(
          name: 'Example User',
          username: 'example',
          access_token: 'token',
          access_token_secret: 'secret'
        )
        User.register(
          name: 'Someone Else',
          username: 'someoneelse'
        )

        stub_request(:post, STATUS_UPDATE_URL).to_return(
          body: File.new(tweet),
          headers: { content_type: 'application/json; charset=utf-8' }
        )
      end

      context 'and the client is a different user' do
        before do
          jwt sub: 'someoneelse'
        end

        it 'returns a forbidden response' do
          post '/users/example/tweets', 'This is my tweet text'
          expect(last_response.status).to be 403
        end
      end

      context 'and the client is the same user' do
        before do
          jwt sub: 'example'
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

      context 'and the client is another microservice' do
        before do
          jwt sub: 'courier-posts', roles: ['service']
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
  end
end
