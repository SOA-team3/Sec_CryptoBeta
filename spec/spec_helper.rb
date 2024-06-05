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

def auth_header(account_data)
  auth = No2Date::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )

  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {
  accounts: YAML.safe_load_file('app/db/seeds/accounts_seed.yml'),
  events: YAML.safe_load_file('app/db/seeds/events_seed.yml'),
  appointments: YAML.safe_load_file('app/db/seeds/appointments_seed.yml')
}.freeze
