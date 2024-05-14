# frozen_string_literal: true

require 'roda'
require_relative './app'

module No2Date
  # Web controller for No2Date API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('schedules') do |routing|
        @sched_route = "#{@api_root}/schedules"
  
    # if the "account" is directing to "schedules"
      routing.on String do |sched_id|
        # GET api/v1/schedules/[ID]
        routing.get do
          sched = Schedule.first(id: sched_id)
          sched ? sched.to_json : raise('Schedule not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET api/v1/schedules
      routing.get do
        output = { data: Schedule.all }
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 404, { message: 'Could not find schedules' }.to_json
      end

      # POST api/v1/schedules
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_sched = Schedule.new(new_data)
        raise('Could not save schedules') unless new_sched.save

        response.status = 201
        response['Location'] = "#{@sched_route}/#{new_sched.id}"
        { message: 'Schedule saved', data: new_sched }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue StandardError => e
        Api.logger.error "UNKOWN ERROR: #{e.message}"
        routing.halt 500, { message: 'Unknown server error' }.to_json
      end
    end
  end
end
