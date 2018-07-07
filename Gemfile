source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in courier-tweeter.gemspec
gemspec

gem 'puma'

group :test do
  gem 'rack-test'
end

group :production do
  gem 'google-cloud-storage'
end
