# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Schedule Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:meetings].each do |meeting_data|
      No2Date::Meeting.create(meeting_data)
    end
  end

  it 'HAPPY: should be able to get list of all schedules' do
    meet = No2Date::Meeting.first
    DATA[:schedules].each do |sched|
      meet.add_schedule(sched)
    end

    get "api/v1/meetings/#{meet.id}/schedules"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single schedule' do
    sched_data = DATA[:schedules][1]
    meet = No2Date::Meeting.first
    sched = meet.add_schedule(sched_data)

    get "/api/v1/meetings/#{meet.id}/schedules/#{sched.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal sched.id
    _(result['data']['attributes']['title']).must_equal sched_data['title']
    _(result['data']['attributes']['description']).must_equal sched_data['description']
    _(result['data']['attributes']['location']).must_equal sched_data['location']
    _(result['data']['attributes']['start_date']).must_equal sched_data['start_date']
    _(result['data']['attributes']['start_datetime']).must_equal sched_data['start_datetime']
    _(result['data']['attributes']['end_date']).must_equal sched_data['end_date']
    _(result['data']['attributes']['end_datetime']).must_equal sched_data['end_datetime']
    _(result['data']['attributes']['is_regular']).must_equal sched_data['is_regular']
    _(result['data']['attributes']['is_flexible']).must_equal sched_data['is_flexible']
  end

  it 'SAD: should return error if unknown schedule requested' do
    meet = No2Date::Meeting.first
    get "/api/v1/meetings/#{meet.id}/schedules/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Schedules' do
    before do
      @meet = No2Date::Meeting.first
      @sched_data = DATA[:schedules][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new schedules' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post "api/v1/meetings/#{@meet.id}/schedules",
           @sched_data.to_json, req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      sched = No2Date::Schedule.first

      _(created['id']).must_equal sched.id
      _(created['title']).must_equal @sched_data['title']
      _(created['description']).must_equal @sched_data['description']
      _(created['location']).must_equal @sched_data['location']
      _(created['start_date']).must_equal @sched_data['start_date']
      _(created['start_datetime']).must_equal @sched_data['start_datetime']
      _(created['end_date']).must_equal @sched_data['end_date']
      _(created['end_datetime']).must_equal @sched_data['end_datetime']
      _(created['is_regular']).must_equal @sched_data['is_regular']
      _(created['is_flexible']).must_equal @sched_data['is_flexible']
    end

    it 'SECURITY: should not create schedules with mass assignment' do
      bad_data = @sched_data.clone
      bad_data['created_at'] = '1990-01-01'
      post "api/v1/meetings/#{@meet.id}/schedules",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
