# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:schedules) do
      primary_key :id
      foreign_key :meeting_id, table: :meetings

      String :title
      String :description
      String :location
      Date :start_date, null: false
      DateTime :start_datetime, null: false
      Date :end_date, null: false
      DateTime :end_datetime, null: false
      TrueClass :is_regular # bool
      TrueClass :is_flexible
      String :description_secure
      String :content_secure, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
