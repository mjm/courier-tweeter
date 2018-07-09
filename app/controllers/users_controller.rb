class UsersController < ApplicationController
  post '/users' do
    require_service_client
    User.register JSON.parse(request.body.read)
  end
end
