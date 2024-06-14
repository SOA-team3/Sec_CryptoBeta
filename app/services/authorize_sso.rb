# frozen_string_literal: true

require 'http'

module No2Date
  # Find or create an SsoAccount based on Google code
  class AuthorizeSso
    def call(access_token)
      goog_account = get_goog_account(access_token)
      sso_account = find_or_create_sso_account(goog_account)

      account_and_token(sso_account)
    end

    def get_goog_account(access_token)
      goog_response = HTTP.headers(
        user_agent: 'No2Date',
        authorization: "token #{access_token}",
        accept: 'application/json'
      ).get(ENV['goog_account_URL'])

      raise unless goog_response.status == 200

      account = GoogleAccount.new(JSON.parse(goog_response))
      { username: account.username, email: account.email }
    end

    def find_or_create_sso_account(account_data)
      Account.first(email: account_data[:email]) ||
        Account.create_goog_account(account_data)
    end

    def account_and_token(account)
      {
        type: 'sso_account',
        attributes: {
          account: account,
          auth_token: AuthToken.create(account)
        }
      }
    end
  end
end