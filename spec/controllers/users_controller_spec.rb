RSpec.describe UsersController do
  include ControllerSpec

  describe 'POST /users' do
    let(:attributes) do
      {
        username: 'example',
        name: 'Example',
        access_token: 'foo',
        access_token_secret: 'bar'
      }
    end

    context 'when the client is not logged in' do
      it 'returns an unauthorized response' do
        post '/users', attributes
        expect(last_response.status).to be 401
      end
    end

    context 'when the client is logged in as a user' do
      before do
        User.register(username: 'someone', name: 'Some One')
        jwt sub: 'someone'
      end

      it 'returns a forbidden response' do
        post '/users', attributes
        expect(last_response.status).to be 403
      end
    end

    context 'when the client is another microservice' do
      before do
        jwt sub: 'courier-gateway', roles: ['service']
      end

      it 'registers a new user' do
        post '/users', attributes.to_json
        expect(User.lookup('example')).to have_attributes(attributes)
      end

      let(:expected_json) do
        attributes
          .transform_keys(&:to_s)
          .merge('id' => User.lookup('example').id)
      end

      it 'returns the user data as JSON' do
        post '/users', attributes.to_json
        expect(JSON.parse(last_response.body)).to eq expected_json
        expect(last_response.headers['Content-Type']).to eq 'application/json'
      end
    end
  end
end
