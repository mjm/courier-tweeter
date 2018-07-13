source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'omniauth'
gem 'omniauth-twitter'
gem 'pg'
gem 'puma'
gem 'rack'
gem 'rake', '~> 10.0'
gem 'sequel'
gem 'sinatra'
gem 'twitter'

group :development do
  gem 'pry'
end

group :test do
  gem 'rack-test'
  gem 'rspec', '~> 3.0'
  gem 'webmock'
end

group :production do
  gem 'google-cloud-storage'
end
