# frozen_string_literal: true

module No2Date
  # Remove an participant from another owner's existing appointment
  class RemoveParticipant
    # Error for cannot remove
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(auth:, part_email:, appointment_id:)
      appointment = Appointment.first(id: appointment_id)
      participant = Account.first(email: part_email)

      policy = ParticipationRequestPolicy.new(
        appointment, auth[:account], participant, auth[:scope]
      )
      raise ForbiddenError unless policy.can_remove?

      appointment.remove_participant(participant)
      participant
    end
  end
end
