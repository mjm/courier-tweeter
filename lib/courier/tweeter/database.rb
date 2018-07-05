require 'sequel'

DB = Sequel.connect(ENV['DB_URL'])
