require 'sequel'
require 'pathname'

RACK_ENV = (ENV['RACK_ENV'] || 'development').to_sym

DB = Sequel.connect(ENV['DATABASE_URL'])

autoload :User, 'app/models/user'

def require_app(dir)
  Pathname
    .new(__dir__)
    .join('..', 'app', dir.to_s)
    .glob('*.rb')
    .each { |file| require file }
end

require_app :middlewares
require_app :helpers
