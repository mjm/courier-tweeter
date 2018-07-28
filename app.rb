require 'config/environment'

class TweeterHandler
  include Courier::Authorization

  def register_user(req, env)
    require_service env do
      User.register(req.to_hash).to_proto
    end
  end

  def post_tweet(req, env)
    require_token env do
      user = User.lookup(req.username)
      if user
        require_user env, name: user.username, allow_service: true do
          tweet = twitter_client(user).update(req.content)
          Courier::Tweet.new(
            id: tweet.id.to_s,
            text: tweet.text
          )
        end
      else
        Twirp::Error.not_found "No user found with username '#{req.username}'"
      end
    end
  end

  private

  def twitter_client(user)
    Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_API_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_API_SECRET']
      config.access_token = user.access_token
      config.access_token_secret = user.access_token_secret
    end
  end
end

class DocHandler
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) unless doc_request?(env)
    [200, { 'Content-Type' => 'text/html' },
     [File.read(File.join(__dir__, 'doc', 'index.html'))]]
  end

  def doc_request?(env)
    env['REQUEST_METHOD'] == 'GET' && env['PATH_INFO'] =~ %r{^/?$}
  end
end

App = Courier::TweeterService.new(TweeterHandler.new)
