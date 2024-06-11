# frozen_string_literal: true

module No2Date
  # View a event?
  class GetEventQuery
    # Error for owner cannot access
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that event'
      end
    end

    # Error for cannot find a event
    class NotFoundError < StandardError
      def message
        'We could not find that event'
      end
    end

    # Document for given requestor account
    def self.call(auth:, event:)
      raise NotFoundError unless event

      policy = EventPolicy.new(auth[:account], event, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      event
    end
  end
end
