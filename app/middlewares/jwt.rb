require 'jwt'
require 'base64'

class JWTAuth
  def initialize(app, algorithm: 'HS256', secret: Base64.decode64(ENV['JWT_SECRET']))
    @app = app
    @algorithm = algorithm
    @secret = secret
  end

  def call(env)
    if (auth = env['HTTP_AUTHORIZATION']) && auth.start_with?('Bearer ')
      decode_token auth, env
    end

    @app.call(env)
  rescue JWT::DecodeError
    [401, { 'Content-Type' => 'text/plain' }, ['The authorization token provided was invalid.']]
  rescue JWT::ExpiredSignature
    [403, { 'Content-Type' => 'text/plain' }, ['The authorization token has expired.']]
  end

  private

  def decode_token(auth, env)
    token = auth.slice(7..-1)
    payload, = JWT.decode(token, @secret, true, algorithm: @algorithm)

    env['jwt.payload'] = payload
  end
end
