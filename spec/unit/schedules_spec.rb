# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Schedule Handling' do
  before do
    wipe_database

    DATA[:schedules].each do |schedule_data|
      No2Date::Meeting.create(schedule_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    sched_data = DATA[:schedules][1]
    puts "schedules_spec.rb #{sched_data}"
    meet = No2Date::Meeting.first
    new_sched = meet.add_schedule(sched_data)

    sched = No2Date::Schedule.find(id: new_sched.id)
    _(sched.title).must_equal sched_data['title']
    _(sched.description).must_equal sched_data['description']
    _(sched.location).must_equal sched_data['location']
    _(sched.start_date).must_equal sched_data['start_date']
    _(sched.start_datetime).must_equal sched_data['start_datetime']
    _(sched.end_date).must_equal sched_data['end_date']
    _(sched.end_datetime).must_equal sched_data['end_datetime']
    _(sched.is_regular).must_equal sched_data['is_regular']
    _(sched.is_flexible).must_equal sched_data['is_flexible']
  end

  # it 'SECURITY: should not use deterministic integers' do
  #   sched_data = DATA[:schedules][1]
  #   meet = No2Date::Schedule.first
  #   new_sched = meet.add_schedule(sched_data)

  #   _(new_sched.id.is_a?(Numeric)).must_equal false
  # end

  # it 'SECURITY: should secure sensitive attributes' do
  #   sched_data = DATA[:schedules][1]
  #   meet = No2Date::Schedule.first
  #   new_sched = meet.add_schedule(sched_data)
  #   stored_sched = app.DB[:schedules].first

  #   _(stored_sched[:secure_description]).wont_equal new_sched.description
  #   _(stored_sched[:secure_location]).wont_equal new_sched.location
  # end
end