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

    def self.call(req_username:, collab_email:, appointment_id:)
      account = Account.first(username: req_username)
      appointment = Appointment.first(id: appointment_id)
      participant = Account.first(email: collab_email)

      policy = ParticipationRequestPolicy.new(appointment, account, participant)
      raise ForbiddenError unless policy.can_remove?

      appointment.remove_participant(participant)
      participant
    end
  end
end
