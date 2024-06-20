# frozen_string_literal: true

module No2Date
  # Maps Google account details to attributes
  class GoogleAccount
    def initialize(goog_account)
      @goog_account = goog_account
    end

    def username
      "#{@goog_account['given_name']}@Google"
    end

    def email
      @goog_account['email']
    end
  end
end
