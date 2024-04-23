# frozen_string_literal: true

require 'json'
require 'sequel'

module No2Date
  # Models a calendar
  class Calendar < Sequel::Model
    one_to_many :events
    plugin :association_dependencies, events: :destroy
    plugin :timestamps

    # rubocop:enable Metrics/MethodLength
    def to_json(options = {})
    JSON(
      {
        data: {
          type: 'calendar',
          attributes: {
            id:,
            url:,
            owner:
          }
        }
      }, options
    )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
