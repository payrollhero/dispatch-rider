source 'https://rubygems.org'

gem "activesupport"
gem "activemodel"
gem "daemons"
gem "retries"

group :development do
  gem "bundler"
  gem "jeweler", "~> 1.8.4"
  gem "rake"
  gem "travis-lint"
  gem "github_changelog_generator"
end

group :development, :test do
  gem "rspec", "~> 2.0"
  gem 'rspec-its', "~> 1.0"
  gem "byebug", platform: :ruby_20, require: !ENV['CI']
end

group :test do
  gem "aws-sdk", "~> 1"
end
