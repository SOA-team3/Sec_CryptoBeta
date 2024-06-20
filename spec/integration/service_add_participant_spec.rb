# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddParticipant service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      No2Date::Account.create(account_data)
    end

    appointment_data = DATA[:appointments].first

    @owner_data = DATA[:accounts][0]
    @owner = No2Date::Account.all[0]
    @participant = No2Date::Account.all[1]
    @appointment = @owner.add_owned_appointment(appointment_data)
  end

  it 'HAPPY: should be able to add a participant to an appointment' do
    auth = authorization(@owner_data)

    No2Date::AddParticipant.call(
      auth:,
      appointment: @appointment,
      part_email: @participant.email
    )

    _(@participant.appointments.count).must_equal 1
    _(@participant.appointments.first).must_equal @appointment
  end

  it 'BAD: should not add owner as an participant' do
    auth = No2Date::AuthenticateAccount.call(
      username: @owner_data['username'],
      password: @owner_data['password']
    )
    _(proc {
      No2Date::AddParticipant.call(
        auth:,
        appointment: @appointment,
        part_email: @owner.email
      )
    }).must_raise No2Date::AddParticipant::ForbiddenError
  end
end
