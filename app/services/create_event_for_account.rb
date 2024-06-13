# frozen_string_literal: true

module No2Date
  # Create new event for an account
  class CreateEventForAccount
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more events'
      end
    end

    def self.call(auth:, event_data:)
      raise ForbiddenError unless auth[:scope].can_write?('events')

      auth[:account].add_event(event_data)
    end
  end
end
