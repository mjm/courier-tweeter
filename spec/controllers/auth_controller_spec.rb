RSpec.describe AuthController do
  include ControllerSpec

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
