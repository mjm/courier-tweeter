require 'sinatra/base'
require 'omniauth'
require 'omniauth-twitter'
require 'twitter'

RACK_ENV = (ENV['RACK_ENV'] || 'development').to_sym

def load_environment
  if RACK_ENV == :production
    # load production environment settings
    require 'google/cloud/storage'
    storage = Google::Cloud::Storage.new
    bucket = storage.bucket ENV['GOOGLE_CLOUD_STORAGE_BUCKET']
    file = bucket.file '.envrc'
    downloaded = file.download
    downloaded.rewind
    downloaded.each_line do |line|
      ENV[$1] = $2 if line =~ /^export (\w+)="(.*)"$/
    end
  end

  require 'config/environment'
  require 'app/middlewares/jwt'
end

def print_jwt_token
  return unless RACK_ENV == :development

  payload = { sub: 'example' }
  token = JWT.encode payload, Base64.decode64(ENV['JWT_SECRET']), 'HS256'
  puts 'You can use the following token to login:'
  puts token
end

load_environment
print_jwt_token

class App < Sinatra::Base
  use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']
  use OmniAuth::Builder do
    provider :twitter, ENV['TWITTER_CONSUMER_API_KEY'], ENV['TWITTER_CONSUMER_API_SECRET']
  end
  use JWTAuth

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

  helpers do
    def current_user
      return request.env['user'] if request.env['user']

      jwt = request.env['jwt.payload']
      return nil unless jwt

      user = User.lookup(jwt['sub'])
      return nil unless user

      request.env['user'] = user
      user
    end

    def service_client?
      request.env.fetch('jwt.payload', {}).fetch('roles', []).include? 'service'
    end

    def check_user(user = nil)
      return if service_client?

      if user
        return if current_user.id == user.id
        error 403
      else
        return if current_user
        error 401
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
end
