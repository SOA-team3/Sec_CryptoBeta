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

DATA = {
  accounts: YAML.safe_load_file('app/db/seeds/account_seeds.yml'),
  schedules: YAML.safe_load_file('app/db/seeds/schedule_seeds.yml'),
  meetings: YAML.safe_load_file('app/db/seeds/meeting_seeds.yml')
}.freeze