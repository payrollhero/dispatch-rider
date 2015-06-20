source 'https://rubygems.org'

gemspec

# only add dev/test gems here, runtime gems should go in the gemspec

# Base
gem "bundler"
gem "rake"

# Gem Stuff
gem 'rubygems-tasks'
gem 'github_changelog_generator'
gem 'yard'

# Testing
gem "rspec", "~> 3.3"

# CI
gem "travis-lint"

# Dev/Debugging
gem "byebug", platform: :ruby_20, require: !ENV['CI']
gem "aws-sdk", "~> 1"
gem "pry"
