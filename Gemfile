# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.2'

# Web
gem 'puma'
gem 'roda'
gem 'slim'

# Configuration
gem 'econfig'
gem 'rake'

# Debugging
gem 'pry'

# Communication
gem 'http'

# Security
gem 'rbnacl'

# Development
group :development do
  gem 'rubocop'
  gem 'rubocop-performance'
end

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'webmock'
end

group :development, :test do
  gem 'rack-test'
  gem 'rerun'
end

# VSCode extension
gem 'solargraph', group: :development
