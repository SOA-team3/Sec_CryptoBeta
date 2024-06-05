# frozen_string_literal: true

module No2Date
  # Service object to create a new appointment for an owner
  class CreateAppointmentForOwner
    def self.call(owner_id:, appointment_data:)
      Account.find(id: owner_id)
             .add_owned_appointment(appointment_data)
    end
  end
end
