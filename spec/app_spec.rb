RSpec.describe TweeterHandler do
  subject { App }

  Token = Courier::Middleware::JWTToken
  let(:env) { {} }

  shared_examples 'an unauthenticated response' do
    it 'returns an unauthenticated error' do
      expect(response).to be_a_twirp_error :unauthenticated
    end
  end

  shared_examples 'a forbidden response' do
    it 'returns a forbidden error' do
      expect(response).to be_a_twirp_error :permission_denied
    end
  end

  describe '#register_user' do
    let(:request) do
      {
        username: 'example',
        name: 'Example',
        access_token: 'foo',
        access_token_secret: 'bar'
      }
    end
    let(:response) { subject.call_rpc(:RegisterUser, request, env) }

    context 'when the client is not logged in' do
      include_examples 'an unauthenticated response'
    end

    context 'when the client is logged in as a user' do
      let(:env) { { token: Token.new('sub' => 'example') } }

      include_examples 'a forbidden response'
    end

    context 'when the client is another microservice' do
      let(:env) do
        { token: Token.new('sub' => 'courier-gateway', 'roles' => ['service']) }
      end

      it 'registers a new user' do
        response
        expect(User.lookup('example')).to have_attributes(request)
      end

      let(:expected) { request.merge(id: User.lookup('example').id) }

      it 'returns a description of the user' do
        expect(response.to_hash).to match expected
      end
    end
  end

  describe '#post_tweet' do
    let(:request) { { username: 'example', body: 'This is my tweet text' } }
    let(:response) { subject.call_rpc(:PostTweet, request, env) }

    context 'when the client is not logged in' do
      include_examples 'an unauthenticated response'
    end

    context 'when the user does not exist' do
      let(:env) { { token: Token.new('sub' => 'courier-posts') } }

      it 'returns a not found error' do
        expect(response).to be_a Twirp::Error
        expect(response.code).to be :not_found
      end
    end

    context 'when the user exists' do
      STATUS_UPDATE_URL = 'https://api.twitter.com/1.1/statuses/update.json'.freeze
      let(:tweet) { Pathname.new(__dir__).join('fixtures', 'tweet.json') }

      before do
        User.register(
          name: 'Example User',
          username: 'example',
          access_token: 'token',
          access_token_secret: 'secret'
        )
        User.register(name: 'Someone Else', username: 'someoneelse')
        stub_request(:post, STATUS_UPDATE_URL).to_return(
          body: File.new(tweet),
          headers: { content_type: 'application/json; charset=utf-8' }
        )
      end

      context 'and the client is a different user' do
        let(:env) { { token: Token.new('sub' => 'someoneelse') } }

        include_examples 'a forbidden response'
      end

      shared_examples 'successful request' do
        it 'returns a description of the posted tweet' do
          expect(response.to_hash).to match(
            id: '540897316908331009',
            text: 'This is my tweet text'
          )
        end

        it 'posts the tweet to Twitter' do
          response
          expect(a_request(:post, STATUS_UPDATE_URL).with({
            body: { status: 'This is my tweet text' }
          })).to have_been_made
        end
      end

      context 'and the client is the same user' do
        let(:env) { { token: Token.new('sub' => 'example') } }

        include_examples 'successful request'
      end

      context 'and the client is another microservice' do
        let(:env) do
          { token: Token.new('sub' => 'courier-posts', 'roles' => ['service']) }
        end

        include_examples 'successful request'
      end
    end
  end
end
