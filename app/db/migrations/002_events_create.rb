# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:events) do
      primary_key :id
      foreign_key :calendar_id, table: :calendars

      String :title, null: false
      String :description
      String :location
      Date :start_date
      DateTime :start_datetime
      Date :end_date
      DateTime :end_datetime
      String :organizer
      String :attendees

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
