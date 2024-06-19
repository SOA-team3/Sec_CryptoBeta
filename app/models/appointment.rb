# frozen_string_literal: true

require 'json'
require 'sequel'

module No2Date
  # Models a appointment
  class Appointment < Sequel::Model
    many_to_one :owner, class: :'No2Date::Account'

    many_to_many :participants,
                 class: :'No2Date::Account',
                 join_table: :accounts_appointments,
                 left_key: :appointment_id, right_key: :participant_id

    one_to_many :accounts

    plugin :association_dependencies,
           participants: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :description

    # Secure getters and setters
    # def attendees
    #   SecureDB.decrypt(secure_attendees)
    # end

    # def attendees=(plaintext)
    #   self.secure_attendees = SecureDB.encrypt(plaintext)
    # end

    def to_h
      {
        type: 'appointment',
        attributes: {
          id:,
          name:,
          description:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner:,
          participants:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
