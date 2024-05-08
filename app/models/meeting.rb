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

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'meeting',
            attributes: {
              id:,
              name:,
              description:,
              organizer:,
              attendees:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
