# frozen_string_literal: true

require 'json'

module No2Date
  # get all schedules of all participants in a meeting
  class HandleSchedulesUnderMeeting
    def initialize(account, meeting)
      @account = account 
      @meeting = meeting
      @all_schedules = []
    end

    def find_schedules
      # Retrieve schedules for the meeting owner
      @meeting.owner.schedules.each do |schedule|
        schedule_data = schedule.to_json

        # Add the schedule data to the array
        @all_schedules << schedule_data
      end

      @meeting.attenders.each do |attender|
        # Retrieve schedules for each attender
        attender.schedules.each do |schedule|
          schedule_data = schedule.to_json

          # Add the schedule data to the array
          @all_schedules << schedule_data
        end
      end

      # Return collected schedules
      @all_schedules
    end

    # SHOULD HAVE METHOD TO SEND TO VALUE TO CALCULATE AVAILABLE TIME
  end
end
