# frozen_string_literal: true

module No2Date
  # For view meeting?
  class GetMeetingQuery
    # Error for cannot access
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that meeting'
      end
    end

    # Error for cannot find a meeting
    class NotFoundError < StandardError
      def message
        'We could not find that meeting'
      end
    end

    def self.call(account:, meeting:)
      raise NotFoundError unless meeting

      policy = MeetingPolicy.new(account, meeting)
      raise ForbiddenError unless policy.can_view?

      meeting_with_policy = meeting.full_details.merge(policies: policy.summary)

      schedules_under_meeting = HandleSchedulesUnderMeeting.new(account, meeting).find_schedules

      meeting_json = meeting_with_policy.merge(schedules_under_meeting:)

      meeting_json
    end
  end
end
