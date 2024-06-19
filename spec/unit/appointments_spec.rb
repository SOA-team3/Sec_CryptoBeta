# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Appointment Handling' do
  before do
    wipe_database

    # DATA[:accounts].each do |account_data|
    #   No2Date::Account.create(account_data)
    # end
    DATA[:appointments].each do |appointment_data|
      No2Date::Appointment.create(appointment_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    appt_data = DATA[:appointments][0]
    # account = No2Date::Account.first
    # new_appt = account.add_appointment(appt_data)

    # appointment = No2Date::Appointment.first
    # new_appt = appointment.add_appointment(appt_data)

    new_appt = No2Date::Appointment.first
    appt = No2Date::Appointment.find(id: new_appt.id)

    _(appt.name).must_equal appt_data['name']
    _(appt.description).must_equal appt_data['description']
  end

  # it 'SECURITY: should secure sensitive attributes' do
  #   DATA[:appointments][0]
  #   # account = No2Date::Account.first
  #   # new_appt = account.add_appointment(appt_data)
  #   new_appt = No2Date::Appointment.first
  #   stored_appt = app.DB[:appointments].first

  #   _(stored_appt[:secure_attendees]).wont_equal new_appt.attendees
  # end
end
