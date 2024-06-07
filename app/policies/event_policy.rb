# frozen_string_literal: true

module No2Date
  # Policy to determine if account can view a event
  class EventPolicy
    def initialize(account, event)
      @account = account
      @event = event
    end

    def can_view?
      account_owns_event?
    end

    def can_edit?
      account_owns_event?
    end

    def can_delete?
      account_owns_event?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?
      }
    end

    private

    def account_owns_event?
      @event.account == @account
    end
  end
end
