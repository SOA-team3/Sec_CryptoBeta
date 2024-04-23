# frozen_string_literal: true

require 'roda'
require 'json'

module No2Date
  # Web controller for No2Date API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'No2DateAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'calendars' do
          @calendar_route = "#{@api_root}/calendars"

          routing.on String do |calendar_id|
            routing.on 'events' do
              @event_route = "#{@api_root}/calendars/#{calendar_id}/events"
              # GET api/v1/calendars/[calendar_id]/events/[event_id]
              routing.get String do |event_id|
                event = Event.where(calendar_id:, id: event_id).first
                event ? event.to_json : raise('Event not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/calendars/[calendar_id]/events
              routing.get do
                output = { data: Calendar.first(id: calendar_id).events }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find events'
              end

              # POST api/v1/calendars/[ID]/events
              routing.post do
                new_data = JSON.parse(routing.body.read)
                calendar = Calendar.first(id: calendar_id)
                new_event = calendar.add_event(new_data)

                if new_event
                  response.status = 201
                  response['Location'] = "#{@event_route}/#{new_event.id}"
                  { message: 'Event saved', data: new_event }.to_json
                else
                  routing.halt 400, 'Could not save event'
                end
              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/calendars/[ID]
            routing.get do
              calendar = Calendar.first(id: calendar_id)
              calendar ? calendar.to_json : raise('Calendar not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/calendars
          routing.get do
            output = { data: Calendar.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find calendars' }.to_json
          end

          # POST api/v1/calendars
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_calendar = Calendar.new(new_data)
            raise('Could not save calendar') unless new_calendar.save

            response.status = 201
            response['Location'] = "#{@calendar_route}/#{new_calendar.id}"
            { message: 'Calendar saved', data: new_calendar }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end
    end
  end
end
