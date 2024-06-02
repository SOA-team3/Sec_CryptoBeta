# frozen_string_literal: true

# Policy to determine if account can view a schedule
class SchedulePolicy
    def initialize(account, schedule)
      @account = account
      @schedule = schedule
    end
  
    def can_view?
      account_owns_schedule?
    end
  
    def can_edit?
      account_owns_schedule?
    end
  
    def can_delete?
      account_owns_schedule?
    end
  
    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?
      }
    end
  
    private
  
    def account_owns_schedule?
      @schedule.account == @account
    end
end