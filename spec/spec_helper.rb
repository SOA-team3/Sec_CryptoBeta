# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:schedules].delete
  app.DB[:meetings].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:schedules] = YAML.safe_load_file('app/db/seeds/schedule_seeds.yml')
DATA[:meetings] = YAML.safe_load_file('app/db/seeds/meeting_seeds.yml')

puts DATA
puts DATA[:meetings][0]
