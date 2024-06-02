# frozen_string_literal: true

require 'roda'
require_relative 'app'

module No2Date
  # Web controller for No2Date API
  class Api < Roda
    route('meetings') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @meet_route = "#{@api_root}/meetings"
      # if the "account" is directing to "meetings"
      routing.on String do |meet_id|
        account = Account.first(username: @auth_account['username'])
        @req_meeting = Meeting.first(id: meet_id)

        # GET api/v1/meetings/[ID]
        routing.get do
          meeting = GetMeetingQuery.call(
            account:, meeting: @req_meeting
          )

          { data: meeting }.to_json
        rescue GetMeetingQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetMeetingQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND MEETING ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        routing.on('attenders') do
          # PUT api/v1/projects/[proj_id]/attenders
          routing.put do
            req_data = JSON.parse(routing.body.read)

            attender = AddAttender.call(
              account: @auth_account,
              meeting: @req_meeting,
              attend_email: req_data['email']
            )

            { data: attender }.to_json
          rescue AddAttender::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/projects/[proj_id]/attenders
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            attender = RemoveAttender.call(
              req_username: @auth_account.username,
              attend_email: req_data['email'],
              meet_id:
            )

            { message: "#{attender.username} removed from projet",
              data: attender }.to_json
          rescue RemoveAttender::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      routing.is do
        # GET api/v1/meetings
        routing.get do
          account = Account.first(username: @auth_account['username'])
          meetings = MeetingPolicy::AccountScope.new(account).viewable

          JSON.pretty_generate(data: meetings)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any meetings' }.to_json
        end

        # POST api/v1/meetings
        routing.post do
          new_data = JSON.parse(routing.body.read)
          account = Account.first(username: @auth_account['username'])
          new_meet = account.add_owned_meeting(new_data)

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
end
