# frozen_string_literal: true

module No2Date
  # Add an attender to another owner's existing meeting
  class AddAttenderToMeeting
    # Error for owner cannot be attender
    class OwnerNotAttenderError < StandardError
      def message = 'Organizer cannot be attendee of meeting'
    end

    def self.call(email:, meeting_id:)
      attender = Account.first(email:)
      meeting = Meeting.first(id: meeting_id)
      raise(OwnerNotAttenderError) if meeting.owner.id == attender.id

      meeting.add_attender(attender)
    end
  end
end
