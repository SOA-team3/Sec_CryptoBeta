
# frozen_string_literal: true

module No2Date
    # Policy to determine if an account can view a particular meeting
    class AttendanceRequestPolicy
      def initialize(meeting, requestor_account, target_account)
        @meeting = meeting
        @requestor_account = requestor_account
        @target_account = target_account
        @requestor = MeetingPolicy.new(requestor_account, meeting)
        @target = MeetingPolicy.new(target_account, meeting)
      end
  
      def can_invite?
        @requestor.can_add_attenders? && @target.can_attend?
      end
  
      def can_remove?
        @requestor.can_remove_attenders? && target_is_attender?
      end
  
      private
  
      def target_is_attender?
        @meeting.attenders.include?(@target_account)
      end
    end
  end
  