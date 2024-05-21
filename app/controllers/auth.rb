# frozen_string_literal: true

require 'roda'
require_relative 'app'

module No2Date
  # Web controller for No2Date API
  class Api < Roda
    route('auth') do |routing|
      routing.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        routing.post do
          credentials = JSON.parse(request.body.read, symbolize_names: true)
          auth_account = AuthenticateAccount.call(credentials)
          auth_account.to_json
        rescue UnauthorizedError
          # puts [e.class, e.message].join ': '
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end
    end
  end
end
