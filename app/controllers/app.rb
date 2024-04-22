# frozen_string_literal: true

require 'roda'
require 'json'
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require_relative '../models/calendar'

module Calendar
  # Web controller for Calendar API
  class Api < Roda
    plugin :environments
    # halt hard return from routes
    plugin :halt

    configure do
      Event.setup
    end

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'CalendarAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'calendars' do
            # GET api/v1/calendars/[id]
            routing.get String do |id|
              response.status = 200
              Event.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Calendar not found' }.to_json
            end

            # GET api/v1/calendars
            routing.get do
              response.status = 200
              output = { event_ids: Event.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/calendars
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_event = Event.new(new_data)

              if new_event.save
                response.status = 201
                { message: 'Calendar saved', id: new_event.id }.to_json
              else
                routing.halt 400, { message: 'Could not save calendar' }.to_json
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
  end
end
