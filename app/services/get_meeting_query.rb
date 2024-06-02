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

        schedules_under_meeting = FindSchedulesUnderMeeting.new.find_schedules(meeting)

        meeting_with_schedule = meeting.full_details.merge(schedules_under_meeting: schedules_under_meeting)
  
        meeting_with_schedule.merge(policies: policy.summary)
      end
    end
  end