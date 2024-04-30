# frozen_string_literal: true

require 'json'
require 'sequel'

module No2Date
  # Models a secret document
  class Schedule < Sequel::Model
    many_to_one :meeting

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :title, :description, :location, :start_date, :start_datetime, :end_date, :end_datetime,
                        :is_regular, :is_flexible

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def content
      SecureDB.decrypt(content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'schedule',
            attributes: {
              id:,
              title:,
              description:,
              location:,
              start_date:,
              start_datetime:,
              end_date:,
              end_datetime:,
              is_regular:, # bool
              is_flexible:
            }
          },
          included: {
            meeting:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
