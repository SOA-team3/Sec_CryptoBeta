# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Schedule Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = No2Date::Account.create(@account_data)
    @wrong_account = No2Date::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting Schedules' do
    describe 'Getting list of schedules' do
      before do
        @account.add_owned_schedule(DATA[:schedules][0])
        @account.add_owned_schedule(DATA[:schedules][1])
      end

      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)

        # auth = No2Date::AuthenticateAccount.call(
        #   username: @account_data['username'],
        #   password: @account_data['password']
        # )

        # header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"

        get 'api/v1/schedules'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process without authorization' do
        get 'api/v1/schedules'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    # it 'HAPPY: should be able to get list of all schedules' do
    #   No2Date::Schedule.create(DATA[:schedules][0])
    #   No2Date::Schedule.create(DATA[:schedules][1])

    #   get 'api/v1/schedules'
    #   _(last_response.status).must_equal 200

    #   result = JSON.parse last_response.body
    #   _(result['data'].count).must_equal 2
    # end

    it 'HAPPY: should be able to get details of a single schedule' do
      sched = @account.add_owned_schedule(DATA[:schedules][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/schedules/#{sched.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal sched.id
      _(result['attributes']['title']).must_equal sched.title
      _(result['attributes']['description']).must_equal sched.description
      _(result['attributes']['location']).must_equal sched.location
      _(result['attributes']['start_date']).must_equal sched.start_date.to_s
      _(result['attributes']['start_datetime']).must_equal sched.start_datetime.to_s
      _(result['attributes']['end_date']).must_equal sched.end_date.to_s
      _(result['attributes']['end_datetime']).must_equal sched.end_datetime.to_s
      _(result['attributes']['is_regular']).must_equal sched.is_regular
      _(result['attributes']['is_flexible']).must_equal sched.is_flexible
    end

    it 'SAD: should return error if unknown schedule requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/schedules/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get schedule with wrong authorization' do
      sched = @account.add_owned_schedule(DATA[:schedules][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/schedules/#{sched.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
      @account.add_owned_schedule(DATA[:schedules][0])
      @account.add_owned_schedule(DATA[:schedules][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/schedules/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Schedules' do
    before do
      @sched_data = DATA[:schedules][1]
    end

    it 'HAPPY: should be able to create new schedules' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/schedules', @sched_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
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

    it 'SAD: should not create new schedule without authorization' do
      post 'api/v1/schedules', @sched_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create schedule with mass assignment' do
      bad_data = @sched_data.clone
      bad_data['created_at'] = '1990-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/schedules', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
