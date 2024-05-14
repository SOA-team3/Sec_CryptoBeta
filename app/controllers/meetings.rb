# frozen_string_literal: true

require 'roda'
require_relative 'app'

module No2Date
  # Web controller for No2Date API
  class Api < Roda
    route('meetings') do |routing|
      @meet_route = "#{@api_root}/meetings"

      # if the "account" is directing to "meetings"
      routing.on String do |meet_id|
        # GET api/v1/meetings/[ID]
        routing.get do
          meet = Meeting.first(id: meet_id)
          meet ? meet.to_json : raise('Meeting not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET api/v1/meetings
      routing.get do
        output = { data: Meeting.all }
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 404, { message: 'Could not find meetings' }.to_json
      end

      # POST api/v1/meetings
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_meet = Meeting.new(new_data)
        raise('Could not save meeting') unless new_meet.save

        response.status = 201
        response['Location'] = "#{@meet_route}/#{new_meet.id}"
        { message: 'Meeting saved', data: new_meet }.to_json
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
