# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Schedule Handling' do
  before do
    wipe_database

    # DATA[:accounts].each do |account_data|
    #   No2Date::Account.create(account_data)
    # end
    DATA[:schedules].each do |schedule_data|
      No2Date::Schedule.create(schedule_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    sched_data = DATA[:schedules][0]
    # account = No2Date::Account.first
    # new_sched = account.add_schedule(sched_data)
    new_sched = No2Date::Schedule.first
    sched = No2Date::Schedule.find(id: new_sched.id)

    _(sched.title).must_equal sched_data['title']
    _(sched.description).must_equal sched_data['description']
    _(sched.location).must_equal sched_data['location']
    _(sched.start_date.to_s).must_equal sched_data['start_date']
    _(sched.start_datetime.to_s).must_equal sched_data['start_datetime']
    _(sched.end_date.to_s).must_equal sched_data['end_date']
    _(sched.end_datetime.to_s).must_equal sched_data['end_datetime']
    _(sched.is_regular).must_equal sched_data['is_regular']
    _(sched.is_flexible).must_equal sched_data['is_flexible']
  end

  # Test for UUID
  it 'SECURITY: should not use deterministic integers' do
    DATA[:schedules][1]
    # account = No2Date::Account.first
    # new_sched = account.add_schedule(sched_data)
    new_sched = No2Date::Schedule.first
    _(new_sched.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    DATA[:schedules][0]
    # account = No2Date::Account.first
    # new_sched = account.add_schedule(sched_data)
    new_sched = No2Date::Schedule.first
    stored_sched = app.DB[:schedules].first

    _(stored_sched[:secure_description]).wont_equal new_sched.description
    _(stored_sched[:secure_location]).wont_equal new_sched.location
  end
end
