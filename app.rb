require 'sinatra/base'
require 'omniauth'
require 'omniauth-twitter'

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
end
