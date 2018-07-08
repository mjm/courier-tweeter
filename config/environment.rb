require 'sequel'

DB = Sequel.connect(ENV['DB_URL'])

autoload :User, 'app/models/user'
