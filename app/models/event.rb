# frozen_string_literal: true

require 'json'
require 'sequel'

module No2Date
  # Models a event
  class Event < Sequel::Model
    many_to_one :account, class: :'No2Date::Account'

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true

    plugin :whitelist_security
    set_allowed_columns :title, :description, :location, :start_datetime, :end_datetime,
                        :is_google, :is_flexible

    # Secure getters and setters
    def description
      SecureDB.decrypt(secure_description)
    end

    def description=(plaintext)
      self.secure_description = SecureDB.encrypt(plaintext)
    end

    def location
      SecureDB.decrypt(secure_location)
    end

    def location=(plaintext)
      self.secure_location = SecureDB.encrypt(plaintext)
    end

    # def start_datetime
    #   SecureDB.decrypt(secure_start_datetime)
    # end

    # def start_datetime=(plaintext)
    #   self.secure_start_datetime = SecureDB.encrypt(plaintext)
    # end

    # def end_datetime
    #   SecureDB.decrypt(secure_end_datetime)
    # end

    # def end_datetime=(plaintext)
    #   self.secure_end_datetime = SecureDB.encrypt(plaintext)
    # end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'event',
          attributes: {
            id:,
            title:,
            description:,
            location:,
            start_datetime:,
            end_datetime:,
            is_google:, # bool
            is_flexible: # bool
          },
          created: {
            account:
          }
        },
        options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end