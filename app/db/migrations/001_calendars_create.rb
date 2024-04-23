# frozen_string_literal: true

require 'sequel'

Sequel.migration do
    change do
        create_table(:calendars) do
            primary_key :id

            String :name, unique: true, null: false
            String :url, unique: true
            String :owner

            DateTime : created_at
            DateTime : updated_at
        end
    end
end