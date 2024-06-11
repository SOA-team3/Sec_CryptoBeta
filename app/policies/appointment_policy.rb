# frozen_string_literal: true

module No2Date
  # Policy to determine if an account can view a particular appointment
  class AppointmentPolicy
    def initialize(account, appointment, auth_scope = nil)
      @account = account
      @appointment = appointment
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (account_is_owner? || account_is_participant?)
    end

    # duplication is ok!
    def can_edit?
      can_write? && (account_is_owner? || account_is_participant?)
    end

    def can_delete?
      can_write? && account_is_owner?
    end

    def can_leave?
      account_is_participant?
    end

    def can_add_participants?
      account_is_owner?
    end

    def can_remove_participants?
      account_is_owner?
    end

    def can_participate?
      !(account_is_owner? or account_is_participant?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_participants: can_add_participants?,
        can_remove_participants: can_remove_participants?,
        can_participate: can_participate?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('participants') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('participants') : false
    end

    def account_is_owner?
      @appointment.owner == @account
    end

    def account_is_participant?
      @appointment.participants.include?(@account)
    end
  end
end
