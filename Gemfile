# frozen_string_literal: true

source 'https://rubygems.org'

# Web API
gem 'json'
gem 'puma', '~>6.1'
gem 'roda', '~>3.1'

# Configuration
gem 'figaro', '~>1.2'
gem 'rake', '~>13.0'

# Security
gem 'bundle-audit'
gem 'rbnacl', '~>7.1'

# Database
gem 'hirb', '~>0.7'
gem 'sequel', '~>5.67'
group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3', '~>1.6'
end

# Performance

# Run `sudo apt-get install pkg-config`` to solve the issue of:
# "Could not find gem 'rubocup-performance' in rubygems repository https://rubygems.org/ or installed locally."
gem 'rubocop-performance'

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'rack-test'
end

# Development
gem 'pry'
gem 'rerun'

# Quality
gem 'rubocop'

# Google Calender API
gem 'google-apis-calendar_v3', '~> 0.5.0'
