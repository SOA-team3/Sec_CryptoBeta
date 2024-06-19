# frozen_string_literal: true
require './app/controllers/helpers.rb'
include No2Date::SecureRequestHelpers

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, appointments, events'
    create_accounts
    create_owned_appointments
    create_events
    add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_appointments.yml")
APPT_INFO = YAML.load_file("#{DIR}/appointments_seed.yml")
EVENT_INFO = YAML.load_file("#{DIR}/events_seed.yml")
CONTRIB_INFO = YAML.load_file("#{DIR}/appointments_collaborators.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    No2Date::Account.create(account_info)
  end
end

def create_owned_appointments
  OWNER_INFO.each do |owner|
    account = No2Date::Account.first(username: owner['username'])
    owner['appt_name'].each do |appt_name|
      appt_data = APPT_INFO.find { |appt| appt['name'] == appt_name }
      
      account.add_owned_project(appt_data)
    end
  end
end

def create_events
  evnt_info_each = EVENT_INFO.each
  appointments_cycle = No2Date::Appointment.all.cycle
  loop do
    evnt_info = evnt_info_each.next
    appointment = appointments_cycle.next

    auth_token = AuthToken.create(appointment.owner)
    auth = scoped_auth(auth_token)
    
    No2Date::CreateEventForAppointment.call(
      auth: auth, appointment_id: appointment.id, event_data: evnt_info
    )
  end
end

def add_collaborators
  contrib_info = CONTRIB_INFO
  contrib_info.each do |contrib|
    appointment = No2Date::Appointment.first(name: contrib['appt_name'])

    auth_token = AuthToken.create(appointment.owner)
    auth = scoped_auth(auth_token)

    contrib['collaborator_email'].each do |email|
      No2Date::AddCollaboratorToAppointment.call(
        auth: auth,  appointment: appointment, part_email: email
      )
    end
  end
end
