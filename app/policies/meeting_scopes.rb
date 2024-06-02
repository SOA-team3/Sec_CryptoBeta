# frozen_string_literal: true

module No2Date
    # Policy to determine if account can view a meeting
    class MeetingPolicy
      # Scope of meeting policies
      class AccountScope
        def initialize(current_account, target_account = nil)
          target_account ||= current_account
          @full_scope = all_meetings(target_account)
          @current_account = current_account
          @target_account = target_account
        end
  
        def viewable
          if @current_account == @target_account
            @full_scope
          else
            @full_scope.select do |meet|
              includes_attender?(meet, @current_account)
            end
          end
        end
  
        private
  
        def all_meetings(account)
          account.owned_meetings + account.attendances
        end
  
        def includes_attender?(meeting, account)
          meeting.attenders.include? account
        end
      end
    end
  end