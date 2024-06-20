# frozen_string_literal: true

require 'json'

module No2Date
  # Handle Events Under Appointment
  class HandleEventsUnderAppointment
    def initialize(account, appointment)
      @account = account
      @appointment = appointment
      @all_events = {}
    end

    def find_events
      # Initialize the owner's events
      add_events_for_user(@appointment.owner)

      # Initialize each participant's events
      @appointment.participants.each do |participant|
        add_events_for_user(participant)
      end

      @all_events
    end

    def add_events_for_user(user)
      user.events.each do |event|
        # Format the event data as start and end datetimes
        event_data = [event.start_datetime.to_s, event.end_datetime.to_s]

        # If the user's username is already a key in @all_events, append the event data
        # Otherwise, create a new array for this user
        @all_events[user.username] ||= []
        @all_events[user.username] << event_data
      end
    end
  end
end
