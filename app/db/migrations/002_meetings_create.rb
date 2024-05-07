# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:meetings) do
      primary_key :id
      foreign_key :owner_id, :accounts

      String :name, null: false
      String :description
      String :organizer, null: false
      String :attendees, null: false # should be array

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
