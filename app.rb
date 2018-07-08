require 'sinatra/base'
require 'omniauth'
require 'omniauth-twitter'
require 'twitter'

def load_environment
  require 'config/environment'
  Dir['app/middlewares/*.rb'].each { |middleware| require middleware }
  Dir['app/helpers/*.rb'].each { |helper| require helper }
end

def print_jwt_token
  payload = { sub: 'example' }
  token = JWT.encode payload, Base64.decode64(ENV['JWT_SECRET']), 'HS256'
  puts 'You can use the following token to login:'
  puts token
end

class App < Sinatra::Base
  load_environment
  print_jwt_token if development?

  use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']
  use OmniAuth::Strategies::Twitter, ENV['TWITTER_CONSUMER_API_KEY'], ENV['TWITTER_CONSUMER_API_SECRET']
  use JWTAuth

  helpers AuthHelpers

  disable :show_exceptions

  get '/' do
    if request.env['jwt.payload']
      puts "Authenticated as #{request.env['jwt.payload']['sub']}"
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

  post '/users/:username/tweets' do
    check_user

    user = User.lookup(params[:username])
    if user
      check_user user

      client = twitter_client(user)
      client.update(request.body.read)
      status 201
      'Tweet created'
    else
      status 404
      'User not found'
    end
  end

  def twitter_client(user)
    Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_API_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_API_SECRET']
      config.access_token = user.access_token
      config.access_token_secret = user.access_token_secret
    end
  end
end
