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
        routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |username|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(username:)
              account ? account.to_json : raise('Account not found')
            rescue StandardError
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.new(new_data)
            raise('Could not save account') unless new_account.save

            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Account created', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => e
            Api.logger.error 'Unknown error saving account'
            routing.halt 500, { message: e.message }.to_json
          end
        end

        # if the "account" is directing to "meetings"
        routing.on 'meetings' do
          @meet_route = "#{@api_root}/meetings"

          routing.on String do |meet_id|
            # GET api/v1/meetings/[ID]
            routing.get do
              meet = Meeting.first(id: meet_id)
              meet ? meet.to_json : raise('Meeting not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end

            # Add 2nd routing into the relation of meeting
            # routing.on 'schedules' do
            #   @sched_route = "#{@api_root}/meetings/#{meet_id}/schedules"
            #   # GET api/v1/meetings/[meet_id]/schedules/[sched_id]
            #   routing.get String do |sched_id|
            #     sched = Schedule.where(meeting_id: meet_id, id: sched_id).first
            #     sched ? sched.to_json : raise('Schedule not found')
            #   rescue StandardError => e
            #     routing.halt 404, { message: e.message }.to_json
            #   end

            #   # GET api/v1/meetings/[meet_id]/schedules
            #   routing.get do
            #     output = { data: Meeting.first(id: meet_id).schedules }
            #     JSON.pretty_generate(output)
            #   rescue StandardError
            #     routing.halt 404, message: 'Could not find schedules'
            #   end

            #   # POST api/v1/meetings/[ID]/schedules
            #   routing.post do
            #     new_data = JSON.parse(routing.body.read)
            #     meet = Meeting.first(id: meet_id)
            #     new_sched = meet.add_schedule(new_data)
            #     raise 'Could not save schedule' unless new_sched

            #     response.status = 201
            #     response['Location'] = "#{@sched_route}/#{new_sched.id}"
            #     { message: 'Schedule saved', data: new_sched }.to_json
            #   rescue Sequel::MassAssignmentRestriction
            #     Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            #     routing.halt 400, { message: 'Illegal Attributes' }.to_json
            #   rescue StandardError => e
            #     routing.halt 500, { message: e.message }.to_json
            #   end
            # end
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
            Api.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: 'Unknown server error' }.to_json
          end
        end

        # if the "account" is directing to "schedules"
        routing.on 'schedules' do
          @sched_route = "#{@api_root}/schedules"

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
  end
end