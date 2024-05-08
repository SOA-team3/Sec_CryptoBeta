# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Schedule Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting Schedule' do
    it 'HAPPY: should be able to get list of all schedules' do
      No2Date::Schedule.create(DATA[:schedules][0])
      No2Date::Schedule.create(DATA[:schedules][1])

      get 'api/v1/schedules'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single schedule' do
      existing_sched = DATA[:schedules][1]
      No2Date::Schedule.create(existing_sched).save
      id = No2Date::Schedule.first.id

      get "/api/v1/schedules/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal id
      _(result['data']['attributes']['title']).must_equal existing_sched['title']
      _(result['data']['attributes']['description']).must_equal existing_sched['description']
      _(result['data']['attributes']['location']).must_equal existing_sched['location']
      _(result['data']['attributes']['start_date']).must_equal existing_sched['start_date']
      _(result['data']['attributes']['start_datetime']).must_equal existing_sched['start_datetime']
      _(result['data']['attributes']['end_date']).must_equal existing_sched['end_date']
      _(result['data']['attributes']['end_datetime']).must_equal existing_sched['end_datetime']
      _(result['data']['attributes']['is_regular']).must_equal existing_sched['is_regular']
      _(result['data']['attributes']['is_flexible']).must_equal existing_sched['is_flexible']
    end

    it 'SAD: should return error if unknown schedule requested' do
      get '/api/v1/schedules/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      No2Date::Schedule.create(title: 'New Schedule', location: 'place1',
                               start_date: '2024-04-19', start_datetime: '2024-04-19 09:00:00 +0800',
                               end_date: '2024-04-20', end_datetime: '2024-04-20 09:00:00 +0800')
      No2Date::Schedule.create(title: 'Newer Schedule', location: 'place2',
                               start_date: '2024-05-19', start_datetime: '2024-05-19 09:00:00 +0800',
                               end_date: '2024-05-20', end_datetime: '2024-05-20 09:00:00 +0800')
      get 'api/v1/schedules/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Schedules' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @sched_data = DATA[:schedules][1]
    end

    it 'HAPPY: should be able to create new schedules' do
      post 'api/v1/schedules', @sched_data.to_json, @req_header
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

    it 'SECURITY: should not create schedule with mass assignment' do
      bad_data = @sched_data.clone
      bad_data['created_at'] = '1990-01-01'
      post 'api/v1/schedules', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
