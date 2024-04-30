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

# puts DATA[:meetings]

# puts DATA[:schedules][1]
# No2Date::Schedule.create(DATA[:schedules][1])

# sched_data = DATA[:schedules][1]

# meet = No2Date::Meeting.first
# puts meet

# new_sched = meet.add_schedule(sched_data)
# sched = No2Date::Meeting.find(id: new_sched.id)
# puts No2Date::Schedule.first.secure_location