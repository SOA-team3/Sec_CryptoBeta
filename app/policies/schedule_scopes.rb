# frozen_string_literal: true

module No2Date
  # Policy to determine if account can view a schedule
  class SchedulePolicy
    # Scope of schedule policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_schedules(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        @full_scope if @current_account == @target_account
      end

      private

      def all_schedules(account)
        account.owned_schedules
      end
    end
  end
end
