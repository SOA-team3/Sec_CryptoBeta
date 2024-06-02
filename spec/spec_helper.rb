# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  No2Date::Schedule.map(&:destroy)
  No2Date::Meeting.map(&:destroy)
  No2Date::Account.map(&:destroy)
end

def auth_header(account_data)
  auth = No2Date::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )

  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {
  accounts: YAML.safe_load_file('app/db/seeds/accounts_seed.yml'),
  schedules: YAML.safe_load_file('app/db/seeds/schedules_seed.yml'),
  meetings: YAML.safe_load_file('app/db/seeds/meetings_seed.yml')
}.freeze
