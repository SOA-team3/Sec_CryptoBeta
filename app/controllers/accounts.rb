# frozen_string_literal: true

require 'roda'
require_relative 'app'

module No2Date
  # Web controller for No2Date API
  class Api < Roda
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on String do |username|
        # GET api/v1/accounts/[username]
        routing.get do
          account = GetAccountQuery.call(
            requestor: @auth_account, username: username
          )
          account ? account.to_json : raise('Account not found')
        rescue StandardError => e
          puts "GET ACCOUNT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API Server Error' }.to_json
        end

      end

      # POST api/v1/accounts
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_account = Account.new(new_data)
        raise('Could not save account') unless new_account.save

        response.status = 201
        response['Location'] = "#{@account_route}/#{new_account.id}"
        # response['Location'] = "#{@account_route}/#{new_account.username}"
        { message: 'Account created', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        # Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => e
        # Api.logger.error 'Unknown error saving account'
        puts "ERROR CREATING ACCOUNT: #{e.inspect}"
        puts e.backtrace
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
