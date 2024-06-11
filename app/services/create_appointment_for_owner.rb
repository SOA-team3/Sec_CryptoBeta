# frozen_string_literal: true

module No2Date
  # Service object to create a new appointment for an owner
  class CreateAppointmentForOwner
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more appointments'
      end
    end

    def self.call(auth:, appointment_data:)
      raise ForbiddenError unless auth[:scope].can_write?('appointments')

      auth[:account].add_owned_appointment(appointment_data)
    end
  end
end
