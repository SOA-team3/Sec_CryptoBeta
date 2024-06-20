# frozen_string_literal: true

require 'http'
require 'uri'
require 'sinatra'
require 'httparty'
# require_relative '../models/google_account.rb'

module No2Date
  # Find or create an SsoAccount based on Google code
  class AuthorizeSso
    def call(access_token, id_token)
      goog_account = get_goog_account(access_token, id_token)
      sso_account = find_or_create_sso_account(goog_account)

      account_and_token(sso_account)
    end

    def get_goog_account(access_token, id_token)
      puts 'authorize_sso.rb, get_goog_account'

      goog_response = HTTParty.get(
        "https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=#{access_token}",
        headers: { 'Authorization' => "Bearer #{id_token}" }
      )

      puts "authorize_sso.rb, get_goog_account: goog_response: #{goog_response}"

      # raise unless goog_response.status == 200

      account_json = JSON.parse(goog_response.body)

      puts "authorize_sso.rb, get_goog_account: account_json: #{account_json}"

      account = GoogleAccount.new(account_json)
      { username: account.username, email: account.email }
    end

    def find_or_create_sso_account(account_data)
      Account.first(email: account_data[:email]) ||
        Account.create_google_account(account_data)
    end

    def account_and_token(account)
      {
        type: 'sso_account',
        attributes: {
          account:,
          auth_token: AuthToken.create(account)
        }
      }
    end
  end
end
