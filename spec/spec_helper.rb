# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  No2Date::Event.map(&:destroy)
  No2Date::Appointment.map(&:destroy)
  No2Date::Account.map(&:destroy)
end

def authenticate(account_data)
  No2Date::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)

  token = AuthToken.new(auth[:attributes][:auth_token])
  account = token.payload['attributes']
  { account: No2Date::Account.first(username: account['username']),
    scope: AuthScope.new(token.scope) }
end

DATA = {
  accounts: YAML.safe_load_file('app/db/seeds/accounts_seed.yml'),
  events: YAML.safe_load_file('app/db/seeds/events_seed.yml'),
  appointments: YAML.safe_load_file('app/db/seeds/appointments_seed.yml')
}.freeze

## SSO fixtures
GOOG_ACCOUNT_RESPONSE = YAML.load_file('spec/fixtures/google_token_response.yml')
GOOD_GOOG_ACCESS_TOKEN = GOOG_ACCOUNT_RESPONSE.keys.first
SSO_ACCOUNT = YAML.load_file('spec/fixtures/sso_account.yml')
