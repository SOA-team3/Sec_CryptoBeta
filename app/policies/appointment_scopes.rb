# frozen_string_literal: true

module No2Date
  # Policy to determine if account can view a appointment
  class AppointmentPolicy
    # Scope of appointment policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_appointments(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |appt|
            includes_participant?(appt, @current_account)
          end
        end
      end

      private

      def all_appointments(account)
        account.owned_appointments + account.participations
      end

      def includes_participant?(appointment, account)
        appointment.participants.include? account
      end
    end
  end
end
