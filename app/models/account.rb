# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module No2Date
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_meetings, class: :'No2Date::Meeting', key: :owner_id
    many_to_many :attendances,
                 class: :'No2Date::Meeting',
                 join_table: :accounts_meetings,
                 left_key: :owner_id, right_key: :meeting_id

    plugin :association_dependencies,
           owned_meetings: :destroy,
           attendances: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def meetings
      owned_meetings + attendances
    end

    def password=(new_password)
      self.password_digest = StoredPassword.digest(new_password)
    end

    def password?(try_password)
      password = No2Date::StoredPassword.from_digest(password_digest)
      password.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          id:,
          username:,
          email:
        }, options
      )
    end
  end
end