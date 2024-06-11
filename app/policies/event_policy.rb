# frozen_string_literal: true

module No2Date
  # Policy to determine if account can view a event
  class EventPolicy
    def initialize(account, event, auth_scope = nil)
      @account = account
      @event = event
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && account_owns_event?
    end

    def can_edit?
      can_write? && account_owns_event?
    end

    def can_delete?
      can_write? && account_owns_event?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('events') : false
    end
  
    def can_write?
      @auth_scope ? @auth_scope.can_write?('events') : false
    end

    def account_owns_event?
      @event.account == @account
    end
  end
end
