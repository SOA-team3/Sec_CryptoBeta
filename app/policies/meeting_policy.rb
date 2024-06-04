# frozen_string_literal: true

module No2Date
  # Policy to determine if an account can view a particular meeting
  class MeetingPolicy
    def initialize(account, meeting)
      @account = account
      @meeting = meeting
    end

    def can_view?
      account_is_owner? || account_is_attender?
    end

    # duplication is ok!
    def can_edit?
      account_is_owner? || account_is_attender?
    end

    def can_delete?
      account_is_owner?
    end

    def can_leave?
      account_is_attender?
    end

    def can_add_attenders?
      account_is_owner?
    end

    def can_remove_attenders?
      account_is_owner?
    end

    def can_attend?
      !(account_is_owner? or account_is_attender?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_attenders: can_add_attenders?,
        can_remove_attenders: can_remove_attenders?,
        can_attend: can_attend?
      }
    end

    private

    def account_is_owner?
      @meeting.owner == @account
    end

    def account_is_attender?
      @meeting.attenders.include?(@account)
    end
  end
end
