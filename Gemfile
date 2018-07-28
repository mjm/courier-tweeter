source 'https://rubygems.org'
ruby '2.5.1'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'courier-service', github: 'mjm/courier-service'
gem 'jwt'
gem 'pg'
gem 'puma'
gem 'rack'
gem 'rake', '~> 10.0'
gem 'sequel'
gem 'twirp'
gem 'twitter'

group :development do
  gem 'pry'
end

group :test do
  gem 'rspec', '~> 3.0'
  gem 'webmock', require: 'webmock/rspec'
end
