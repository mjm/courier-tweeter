require 'sinatra/base'
require 'omniauth'
require 'omniauth-twitter'

module Courier
  module Tweeter
    class App < Sinatra::Base
      use Rack::Session::Cookie
      use OmniAuth::Builder do
        provider :twitter, ENV['TWITTER_CONSUMER_API_KEY'], ENV['TWITTER_CONSUMER_API_SECRET']
      end

      get '/' do
        redirect '/auth/twitter'
      end

      get '/auth/:name/callback' do
        auth_hash = request.env['omniauth.auth']
        "Authenticated as #{auth_hash[:info][:name]}!<br>Token: #{auth_hash[:credentials][:token]}<br>Secret: #{auth_hash[:credentials][:secret]}"
      end
    end
  end
end
