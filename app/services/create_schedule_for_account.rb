# frozen_string_literal: true

module No2Date
  # Create new schedule for an account
  class CreateScheduleForAccount
    def self.call(account_id:, schedule_data:)
      Account.first(id: account_id)
             .add_schedule(schedule_data)
    end
  end
end
