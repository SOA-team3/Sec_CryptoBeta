# frozen_string_literal: true

module No2Date
  # Service object to create a new meeting for an owner
  class CreateMeetingForOwner
    def self.call(owner_id:, meeting_data:)
      Account.find(id: owner_id)
             .add_owned_meeting(meeting_data)
    end
  end
end
