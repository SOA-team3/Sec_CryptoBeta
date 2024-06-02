# frozen_string_literal: true

module No2Date
  # View a schedule?
  class GetScheduleQuery
    # Error for owner cannot access
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that schedule'
      end
    end

    # Error for cannot find a schedule
    class NotFoundError < StandardError
      def message
        'We could not find that schedule'
      end
    end

    # Document for given requestor account
    def self.call(account:, schedule:)
      raise NotFoundError unless schedule

      policy = SchedulePolicy.new(account, schedule)
      raise ForbiddenError unless policy.can_view?

      schedule
    end
  end
end
