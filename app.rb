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

load_environment

class ApplicationController < Sinatra::Base
  def self.inherited(subclass)
    super
    App.use subclass
  end

  helpers AuthHelpers
end

class App < Sinatra::Base
  disable :show_exceptions

  print_jwt_token if development?
  use JWTAuth

  Dir['app/controllers/*.rb'].each { |controller| require controller }
end
