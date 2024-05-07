# frozen_string_literal: true

Sequel.seed(:development) do
    def run
      puts 'Seeding accounts, meetings, schedules'
      create_accounts
      create_owned_meetings
      create_schedules
      add_collaborators
    end
  end
  
  require 'yaml'
  DIR = File.dirname(__FILE__)
  ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
  OWNER_INFO = YAML.load_file("#{DIR}/owners_meetings.yml")
  MEET_INFO = YAML.load_file("#{DIR}/meetings_seed.yml")
  SCHEDULE_INFO = YAML.load_file("#{DIR}/schedules_seed.yml")
  CONTRIB_INFO = YAML.load_file("#{DIR}/meetings_collaborators.yml")
  
  def create_accounts
    ACCOUNTS_INFO.each do |account_info|
      No2Date::Account.create(account_info)
    end
  end
  
  def create_owned_meetings
    OWNER_INFO.each do |owner|
      account = No2Date::Account.first(username: owner['username'])
      owner['meet_name'].each do |meet_name|
        meet_data = MEET_INFO.find { |meet| meet['name'] == meet_name }
        No2Date::CreateMeetingForOwner.call(
          owner_id: account.id, meeting_data: meet_data
        )
      end
    end
  end
  
  def create_schedules
    sched_info_each = SCHEDULE_INFO.each
    meetings_cycle = No2Date::Meeting.all.cycle
    loop do
      sched_info = sched_info_each.next
      meeting = meetings_cycle.next
      No2Date::CreateScheduleForMeeting.call(
        meeting_id: meeting.id, schedule_data: sched_info
      )
    end
  end
  
  def add_collaborators
    contrib_info = CONTRIB_INFO
    contrib_info.each do |contrib|
      meet = No2Date::Meeting.first(name: contrib['meet_name'])
      contrib['collaborator_email'].each do |email|
        No2Date::AddCollaboratorToMeeting.call(
          email:, meeting_id: meet.id
        )
      end
    end
  end