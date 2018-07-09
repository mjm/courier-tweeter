require 'twitter'

class TweetsController < ApplicationController
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
