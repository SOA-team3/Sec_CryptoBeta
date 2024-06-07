# frozen_string_literal: true

module No2Date
  # Policy to determine if an account can view a particular appointment
  class ParticipationRequestPolicy
    def initialize(appointment, requestor_account, target_account)
      @appointment = appointment
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = AppointmentPolicy.new(requestor_account, appointment)
      @target = AppointmentPolicy.new(target_account, appointment)
    end

    def can_invite?
      @requestor.can_add_participants? && @target.can_participate?
    end

    def can_remove?
      @requestor.can_remove_participants? && target_is_participant?
    end

    private

    def target_is_participant?
      @appointment.participants.include?(@target_account)
    end
  end
end
