# frozen_string_literal: true

module No2Date
    # Remove an attender from another owner's existing meeting
    class RemoveAttender
      # Error for cannot remove
      class ForbiddenError < StandardError
        def message
          'You are not allowed to remove that person'
        end
      end
  
      def self.call(req_username:, collab_email:, meeting_id:)
        account = Account.first(username: req_username)
        meeting = Meeting.first(id: meeting_id)
        attender = Account.first(email: collab_email)
  
        policy = AttendanceRequestPolicy.new(meeting, account, attender)
        raise ForbiddenError unless policy.can_remove?
  
        meeting.remove_collaborator(attender)
        attender
      end
    end
  end