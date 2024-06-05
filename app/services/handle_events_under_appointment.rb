# frozen_string_literal: true

require 'json'

module No2Date
  # get all events of all participants in a appointment
  class HandleEventsUnderAppointment
    def initialize(account, appointment)
      @account = account
      @appointment = appointment
      @all_events = []
    end

    def find_events
      # Retrieve events for the appointment owner
      @appointment.owner.events.each do |event|
        event_data = event.to_json

        # Add the event data to the array
        @all_events << event_data
      end

      @appointment.participants.each do |participant|
        # Retrieve events for each participant
        participant.events.each do |event|
          event_data = event.to_json

          # Add the event data to the array
          @all_events << event_data
        end
      end

      # Return collected events
      @all_events
    end

    # SHOULD HAVE METHOD TO SEND TO VALUE TO CALCULATE AVAILABLE TIME
  end
end
