# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(collaborator_id: :accounts, meeting_id: :meetings) #collaborator_id not sure
  end
end