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
      if (user = request_user(req))
        require_user env, name: user.username, allow_service: true do
          user.tweet(req)
        end
      else
        Twirp::Error.not_found "No user found with username '#{req.username}'"
      end
    end
  end

  private

  def request_user(req)
    if req.user_id != 0
      User[req.user_id]
    else
      User.lookup(req.username)
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

App.before do |rack_env, env|
  env[:token] = rack_env['jwt.token']
end
