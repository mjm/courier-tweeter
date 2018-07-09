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
    end
  end
end
