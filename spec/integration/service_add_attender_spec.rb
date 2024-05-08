# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../app/services/add_attender_to_meeting.rb'
require_relative '../../app/services/create_meeting_for_owner.rb'
require_relative '../../app/services/create_schedule_for_account.rb'

describe 'Test AddAttenderToMeeting service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      No2Date::Account.create(account_data)
    end

    meeting_data = DATA[:meetings].first

    @owner = No2Date::Account.all[0]
    @attender = No2Date::Account.all[1]
    @meeting = No2Date::CreateMeetingForOwner.call(
      owner_id: @owner.id, meeting_data:
    )
  end

  it 'HAPPY: should be able to add a attender to a meeting' do
    No2Date::AddAttenderToMeeting.call(
      email: @attender.email,
      meeting_id: @meeting.id
    )

    _(@attender.meetings.count).must_equal 1
    _(@attender.meetings.first).must_equal @meeting
  end

  it 'BAD: should not add owner as an attender' do
    _(proc {
      No2Date::AddAttenderToMeeting.call(
        email: @owner.email,
        meeting_id: @meeting.id
      )
    }).must_raise No2Date::AddAttenderToMeeting::OwnerNotAttenderError
  end
end
