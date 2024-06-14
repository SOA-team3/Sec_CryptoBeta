# frozen_string_literal: true

require 'roda'
require_relative 'app'

# rubocop:disable Metrics/BlockLength
module No2Date
  # Web controller for No2Date API
  class Api < Roda
    route('events') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @evnt_route = "#{@api_root}/events"
      # if the "account" is directing to "events"
      routing.on String do |evnt_id|
        # account = Account.first(username: @auth_account['username'])
        @req_event = Event.first(id: evnt_id)

        # GET api/v1/events/[ID]
        routing.get do
          event = GetEventQuery.call(auth: @auth, event: @req_event)

          { data: event}.to_json
        rescue GetEventQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetEventQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND EVENT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end

      routing.is do
        # GET api/v1/events
        routing.get do
          # account = Account.first(username: @auth_account['username'])
          events = EventPolicy::AccountScope.new(@auth_account).viewable

          JSON.pretty_generate(data: events)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any events' }.to_json
        end

        # POST api/v1/events
        routing.post do
          new_data = JSON.parse(routing.body.read)
          # account = Account.first(username: @auth_account['username'])
          new_evnt = CreateEventForAccount.call(
            auth: @auth, event_data: new_data
          )

          response.status = 201
          response['Location'] = "#{@evnt_route}/#{new_evnt.id}"
          { message: 'Event saved', data: new_evnt }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          Api.logger.error "UNKNOWN ERROR: #{e.message}"
          routing.halt 500, { message: 'Unknown server error' }.to_json
        end
      end
    end
  end
end
