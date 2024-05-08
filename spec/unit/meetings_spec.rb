# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Meeting Handling' do
  before do
    wipe_database

    # DATA[:accounts].each do |account_data|
    #   No2Date::Account.create(account_data)
    # end
    DATA[:meetings].each do |meeting_data|
      No2Date::Meeting.create(meeting_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    meet_data = DATA[:meetings][0]
    # account = No2Date::Account.first
    # new_meet = account.add_meeting(meet_data)

    # meeting = No2Date::Meeting.first
    # new_meet = meeting.add_meeting(meet_data)

    new_meet = No2Date::Meeting.first
    meet = No2Date::Meeting.find(id: new_meet.id)

    _(meet.name).must_equal meet_data['name']
    _(meet.description).must_equal meet_data['description']
    _(meet.organizer).must_equal meet_data['organizer']
    _(meet.attendees).must_equal meet_data['attendees']
  end

  it 'SECURITY: should secure sensitive attributes' do
    DATA[:meetings][0]
    # account = No2Date::Account.first
    # new_meet = account.add_meeting(meet_data)
    new_meet = No2Date::Meeting.first
    stored_meet = app.DB[:meetings].first

    _(stored_meet[:secure_attendees]).wont_equal new_meet.attendees
  end
end
