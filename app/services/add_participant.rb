# frozen_string_literal: true

module No2Date
  # Add an participant to another owner's existing appointment
  class AddParticipant
    # Error for owner cannot be participant
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as participant'
      end
    end

    def self.call(account:, appointment:, part_email:)
      invitee = Account.first(email: part_email)
      policy = ParticipationRequestPolicy.new(appointment, account, invitee)
      raise ForbiddenError unless policy.can_invite?

      appointment.add_participant(invitee)
      invitee
    end
  end
end
