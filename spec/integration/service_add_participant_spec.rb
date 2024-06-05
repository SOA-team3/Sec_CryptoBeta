# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddParticipant service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      No2Date::Account.create(account_data)
    end

    appointment_data = DATA[:appointments].first

    @owner = No2Date::Account.all[0]
    @participant = No2Date::Account.all[1]
    @appointment = No2Date::CreateAppointmentForOwner.call(
      owner_id: @owner.id, appointment_data:
    )
  end

  it 'HAPPY: should be able to add a participant to a appointment' do
    No2Date::AddParticipant.call(
      account: @owner,
      appointment: @appointment,
      part_email: @participant.email
    )

    _(@participant.appointments.count).must_equal 1
    _(@participant.appointments.first).must_equal @appointment
  end

  it 'BAD: should not add owner as an participant' do
    _(proc {
      No2Date::AddParticipant.call(
        account: @owner,
        appointment: @appointment,
        part_email: @owner.email
      )
    }).must_raise No2Date::AddParticipant::ForbiddenError
  end
end
