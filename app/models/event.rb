# frozen_string_literal: true

require 'json'
require 'sequel'

module Credence
  # Models a secret document
  class Document < Sequel::Model
    many_to_one :calendar

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'event',
            attributes: {
              id:,
              title:,
              description:,
              location:,
              start_date:,
              start_datetime:,
              end_date:,
              end_datetime:,
              organizer:,
              attendees:
            }
          },
          included: {
            calendar:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
