# frozen_string_literal: true

module No2Date
  # Create new event for an account
  class CreateEventForAccount

    def self.call(auth:, event_data:)
      raise ForbiddenError unless auth[:scope].can_write?('events')

      auth[:account].add_owned_event(event_data)
    end
  end
end
