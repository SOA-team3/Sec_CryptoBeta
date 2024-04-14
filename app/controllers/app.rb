# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/calender_doc'

module Calender
  # Web controller for Calender API
  class Api < Roda
    plugin :environments
    # halt hard return from routes
    plugin :halt

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
        end
      end
    end
  end
end
