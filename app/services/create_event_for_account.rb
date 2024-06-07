# frozen_string_literal: true

module No2Date
  # Create new event for an account
  class CreateEventForAccount
    def self.call(account_id:, event_data:)
      Account.first(id: account_id)
             .add_event(event_data)
    end
  end
end
