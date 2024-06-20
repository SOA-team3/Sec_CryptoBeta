# frozen_string_literal: true

module No2Date
  # Policy to determine if an account can view a particular appointment
  class ParticipationRequestPolicy
    def initialize(appointment, requestor_account, target_account, auth_scope = nil)
      @appointment = appointment
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = AppointmentPolicy.new(requestor_account, appointment, auth_scope)
      @target = AppointmentPolicy.new(target_account, appointment, auth_scope)
    end

    def can_invite?
      can_write? &&
        (@requestor.can_add_participants? && @target.can_participate?)
    end

    def can_remove?
      can_write? &&
        (@requestor.can_remove_participants? && target_is_participant?)
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('pappointmens') : false
    end

    def target_is_participant?
      @appointment.participants.include?(@target_account)
    end
  end
end
