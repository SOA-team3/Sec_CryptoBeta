# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'ymal'

require_relative 'test_load_all'

def wipe_database
  app.DB[:calendars].delete
  app.DB[:events].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA['calendars'] = YAML.safe_load_file('app/db/seeds/calendar_seeds.yml')
DATA['events'] = YAML.safe_load_file('app/db/seeds/event_seeds.yml')