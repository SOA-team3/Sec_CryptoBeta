# frozen_string_literal: true

require 'roda'
require 'json'
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require_relative '../models/calender_doc'

module Calender
  # Web controller for Calender API
  class Api < Roda
    plugin :environments
    # halt hard return from routes
    plugin :halt

     # Google Calendar API configuration
     CALENDAR_SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
     TOKEN_PATH = 'token.yaml'

    configure do
      Event.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'CalenderAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'calenders' do
            # GET api/v1/calenders/[id]
            routing.get String do |id|
              response.status = 200
              Event.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Calender not found' }.to_json
            end

            # GET api/v1/calenders
            routing.get do
              response.status = 200
              output = { event_ids: Event.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/calenders
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_event = Event.new(new_data)

              if new_event.save
                response.status = 201
                { message: 'Calender saved', id: new_event.id }.to_json
              else
                routing.halt 400, { message: 'Could not save calender' }.to_json
              end
            end
          end

          routing.on 'google-calendar' do
            # Example: Retrieve events from Google Calendar
            routing.get 'events' do
              service = Google::Apis::CalendarV3::CalendarService.new
              service.authorization = authorize

              calendar_id = 'primary' # use 'primary' for user's primary calendar

              response.status = 200
              events = service.list_events(calendar_id)
              events.to_json
        end
      end
    end
  end
end

private

    def authorize
      client_id = Google::Auth::ClientId.from_file('google_api.json')
      token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, CALENDAR_SCOPE, token_store)

      user_id = 'default'
      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(base_url: OOB_URI)
        puts 'Open the following URL in the browser and enter the ' \
          "resulting code after authorization:\n#{url}"
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI
        )
      end
      credentials
    end
  end
end