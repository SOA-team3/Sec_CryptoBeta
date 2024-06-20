# frozen_string_literal: true

module No2Date
  # For view appointment?
  class GetAppointmentQuery
    # Error for cannot access
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that appointment'
      end
    end

    # Error for cannot find a appointment
    class NotFoundError < StandardError
      def message
        'We could not find that appointment'
      end
    end

    def self.call(auth:, appointment:)
      raise NotFoundError unless appointment

      policy = AppointmentPolicy.new(auth[:account], appointment, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      appointment_with_policy = appointment.full_details.merge(policies: policy.summary)

      events_under_appointment = HandleEventsUnderAppointment.new(auth[:account], appointment).find_events
      free_time_of_appointment = CalculateFreeTime.new('2024-04-19', '2024-04-20',
                                                       events_under_appointment).call

      appointment_json_with_events = appointment_with_policy.merge(events_under_appointment:)
      appointment_json_with_events.merge(free_time_of_appointment:)
    end
  end
end
