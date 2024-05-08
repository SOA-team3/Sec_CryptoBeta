# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:schedules) do
      # primary_key :id
      uuid :id, primary_key: true
      foreign_key :account_id, table: :accounts

      String :title
      String :secure_description
      String :secure_location
      Date :start_date, null: false # Date :start_date, null: false
      DateTime :start_datetime, null: false # DateTime :start_datetime, null: false
      Date :end_date, null: false # Date :end_date, null: false
      DateTime :end_datetime, null: false # DateTime :end_datetime, null: false
      TrueClass :is_regular # bool
      TrueClass :is_flexible

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
