# frozen_string_literal: true

require 'sequel'

Sequel.migration do
    change do
        create_table(:calendars) do
            primary_key :id

            String :calendar_name, unique: true, null: false
            String :calendar_url, unique: true
            String :calendar_owner

            DateTime : created_at
            DateTime : updated_at
        end
    end
end