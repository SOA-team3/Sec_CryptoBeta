# frozen_string_literal: true

require 'roda'
require_relative 'app'

# rubocop:disable Metrics/BlockLength
module No2Date
  # Web controller for No2Date API
  class Api < Roda
    route('schedules') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @sched_route = "#{@api_root}/schedules"
      # if the "account" is directing to "schedules"
      routing.on String do |sched_id|
        # account = Account.first(username: @auth_account['username'])
        @req_schedule = Schedule.first(id: sched_id)

        # GET api/v1/schedules/[ID]
        routing.get do
          schedule = GetScheduleQuery.call(account:, schedule: @req_schedule)

          { data: schedule }.to_json
        rescue GetScheduleQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetScheduleQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND SCHEDULE ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end

      routing.is do
        # GET api/v1/schedules
        routing.get do
          # account = Account.first(username: @auth_account['username'])
          schedules = SchedulePolicy::AccountScope.new(account).viewable

          JSON.pretty_generate(data: schedules)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any schedules' }.to_json
        end

        # POST api/v1/schedules
        routing.post do
          new_data = JSON.parse(routing.body.read)
          # account = Account.first(username: @auth_account['username'])
          new_sched = account.add_owned_schedule(new_data)

          response.status = 201
          response['Location'] = "#{@sched_route}/#{new_sched.id}"
          { message: 'Schedule saved', data: new_sched }.to_json
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
