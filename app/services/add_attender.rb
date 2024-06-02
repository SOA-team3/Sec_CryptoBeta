# frozen_string_literal: true

module No2Date
  # Add an attender to another owner's existing meeting
  class AddAttender
    # Error for owner cannot be attender
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as attendee'
    end

    def self.call(account:, meeting:, attend_email:)
      invitee = Account.first(email: attend_email)
      policy = AttendanceRequestPolicy.new(account, meeting, invitee)
      raise ForbiddenError unless policy.can_invite?

      meeting.add_attender(invitee)
      invitee
    end
  end
end
