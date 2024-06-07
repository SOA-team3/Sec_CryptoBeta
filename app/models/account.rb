# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative 'password'

module No2Date
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_appointments, class: :'No2Date::Appointment', key: :owner_id

    one_to_many :owned_events, class: :'No2Date::Event', key: :account_id

    many_to_many :participations,
                 class: :'No2Date::Appointment',
                 join_table: :accounts_appointments,
                 left_key: :participant_id, right_key: :appointment_id

    plugin :association_dependencies,
           owned_appointments: :destroy,
           participations: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def appointments
      owned_appointments + participations
    end

    def events
      owned_events
    end

    def password=(new_password)
      self.password_digest = StoredPassword.digest(new_password)
    end

    def password?(try_password)
      password = No2Date::StoredPassword.from_digest(password_digest)
      password.validate?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            username:,
            email:
          }
        }, options
      )
    end
  end
end
