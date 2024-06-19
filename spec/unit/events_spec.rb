# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Event Handling' do
  before do
    wipe_database

    # DATA[:accounts].each do |account_data|
    #   No2Date::Account.create(account_data)
    # end
    DATA[:events].each do |event_data|
      No2Date::Event.create(event_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    evnt_data = DATA[:events][0]
    # account = No2Date::Account.first
    # new_evnt = account.add_event(evnt_data)
    new_evnt = No2Date::Event.first
    evnt = No2Date::Event.find(id: new_evnt.id)

    _(evnt.title).must_equal evnt_data['title']
    _(evnt.description).must_equal evnt_data['description']
    _(evnt.location).must_equal evnt_data['location']
    _(evnt.start_datetime.to_s).must_equal evnt_data['start_datetime']
    _(evnt.end_datetime.to_s).must_equal evnt_data['end_datetime']
    _(evnt.is_google).must_equal evnt_data['is_google']
    _(evnt.is_flexible).must_equal evnt_data['is_flexible']
  end

  # Test for UUID
  it 'SECURITY: should not use deterministic integers' do
    DATA[:events][1]
    # account = No2Date::Account.first
    # new_evnt = account.add_event(evnt_data)
    new_evnt = No2Date::Event.first
    _(new_evnt.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    DATA[:events][0]
    # account = No2Date::Account.first
    # new_evnt = account.add_event(evnt_data)
    new_evnt = No2Date::Event.first
    stored_evnt = app.DB[:events].first

    _(stored_evnt[:secure_description]).wont_equal new_evnt.description
    _(stored_evnt[:secure_location]).wont_equal new_evnt.location
  end
end
