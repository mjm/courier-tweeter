require 'sinatra/base'
require 'omniauth'
require 'omniauth-twitter'

if ENV['RACK_ENV'] == 'production'
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

require 'courier/tweeter'

module Courier
  module Tweeter
    class App < Sinatra::Base
      configure do
        enable :sessions
      end

      use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']
      use OmniAuth::Builder do
        provider :twitter, ENV['TWITTER_CONSUMER_API_KEY'], ENV['TWITTER_CONSUMER_API_SECRET']
      end

      get '/' do
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
        user = Courier::Tweeter::User.register(user_attrs)
        session[:user_id] = user.id
        "Authenticated as #{auth_hash[:info][:name]}!<br>Token: #{auth_hash[:credentials][:token]}<br>Secret: #{auth_hash[:credentials][:secret]}"
      end
    end
  end
end
