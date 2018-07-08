class AuthController < ApplicationController
  use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']
  use OmniAuth::Strategies::Twitter, ENV['TWITTER_CONSUMER_API_KEY'], ENV['TWITTER_CONSUMER_API_SECRET']

  get '/' do
    if token
      puts "Authenticated as #{token.subject}"
    end
    redirect '/auth/twitter'
  end

  get '/auth/:name/callback' do
    auth_hash = request.env['omniauth.auth']
    user_attrs = {
      username: auth_hash[:info][:nickname],
      name: auth_hash[:info][:name],
      access_token: auth_hash[:credentials][:token],
      access_token_secret: auth_hash[:credentials][:secret]
    }
    user = User.register(user_attrs)
    session[:user_id] = user.id
    "Authenticated as #{auth_hash[:info][:name]}!<br>Token: #{auth_hash[:credentials][:token]}<br>Secret: #{auth_hash[:credentials][:secret]}"
  end
end
