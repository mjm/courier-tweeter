require 'sinatra/base'
require 'config/environment'

class ApplicationController < Sinatra::Base
  def self.inherited(subclass)
    super
    App.use subclass
  end

  helpers AuthHelpers
end

class App < Sinatra::Base
  disable :show_exceptions

  use JWTAuth do |auth|
    auth.print_token(sub: 'example') if development?
  end

  require_app :controllers
end
