class UsersController < ApplicationController
  post '/users' do
    require_service_client
    user = User.register JSON.parse(request.body.read)
    content_type :json
    JSON.dump(user.values)
  end
end
