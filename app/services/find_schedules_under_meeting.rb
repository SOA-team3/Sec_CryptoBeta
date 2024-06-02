# frozen_string_literal: true

require 'json'

module No2Date
  # get all schedules of all participants in a meeting
  class FindSchedulesUnderMeeting
    def find_schedules(meeting)
      # Initialize an array to hold all schedules
      all_schedules = []

      meeting.owner.schedules.each do |schedule|
        # Optionally, you could transform the schedule into a hash if needed
        schedule_data = schedule.to_json

        # Add the schedule data to the array
        all_schedules << schedule_data
      end

      meeting.attenders.each do |attender|
        # Retrieve schedules for each attender
        attender.schedules.each do |schedule|
          # Optionally, you could transform the schedule into a hash if needed
          schedule_data = schedule.to_json

          # Add the schedule data to the array
          all_schedules << schedule_data
        end
      end

      # SHOULD BE SENT TO VALUE TO CALCULATE AVAILABLE TIME

      # Return collected schedules
      all_schedules
    end
  end
end
