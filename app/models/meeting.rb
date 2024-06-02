# frozen_string_literal: true

require 'json'
require 'sequel'

module No2Date
  # Models a meeting
  class Meeting < Sequel::Model
    many_to_one :owner, class: :'No2Date::Account'

    many_to_many :attenders,
                 class: :'No2Date::Account',
                 join_table: :accounts_meetings,
                 left_key: :meeting_id, right_key: :attender_id

    one_to_many :accounts

    plugin :association_dependencies,
           attenders: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :description, :organizer, :attendees

    # Secure getters and setters
    def attendees
      SecureDB.decrypt(secure_attendees)
    end

    def attendees=(plaintext)
      self.secure_attendees = SecureDB.encrypt(plaintext)
    end

    def to_h
      {
        type: 'meeting',
        attributes: {
          id:,
          name:,
          description:,
          organizer:,
          attendees:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner:,
          attenders:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
