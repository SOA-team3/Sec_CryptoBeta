# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Event Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = No2Date::Account.create(@account_data)
    @wrong_account = No2Date::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting Events' do
    describe 'Getting list of events' do
      before do
        @account.add_owned_event(DATA[:events][0])
        @account.add_owned_event(DATA[:events][1])
      end

      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)

        # auth = No2Date::AuthenticateAccount.call(
        #   username: @account_data['username'],
        #   password: @account_data['password']
        # )

        # header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"

        get 'api/v1/events'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process without authorization' do
        get 'api/v1/events'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    # it 'HAPPY: should be able to get list of all events' do
    #   No2Date::Event.create(DATA[:events][0])
    #   No2Date::Event.create(DATA[:events][1])

    #   get 'api/v1/events'
    #   _(last_response.status).must_equal 200

    #   result = JSON.parse last_response.body
    #   _(result['data'].count).must_equal 2
    # end

    it 'HAPPY: should be able to get details of a single event' do
      evnt = @account.add_owned_event(DATA[:events][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/events/#{evnt.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal evnt.id
      _(result['attributes']['title']).must_equal evnt.title
      _(result['attributes']['description']).must_equal evnt.description
      _(result['attributes']['location']).must_equal evnt.location
      _(result['attributes']['start_datetime']).must_equal evnt.start_datetime.to_s
      _(result['attributes']['end_datetime']).must_equal evnt.end_datetime.to_s
      _(result['attributes']['is_google']).must_equal evnt.is_google
      _(result['attributes']['is_flexible']).must_equal evnt.is_flexible
    end

    it 'SAD: should return error if unknown event requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/events/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get event with wrong authorization' do
      evnt = @account.add_owned_event(DATA[:events][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/events/#{evnt.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
      @account.add_owned_event(DATA[:events][0])
      @account.add_owned_event(DATA[:events][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/events/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Events' do
    before do
      @evnt_data = DATA[:events][1]
    end

    it 'HAPPY: should be able to create new events' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/events', @evnt_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      evnt = No2Date::Event.first

      _(created['id']).must_equal evnt.id
      _(created['title']).must_equal @evnt_data['title']
      _(created['description']).must_equal @evnt_data['description']
      _(created['location']).must_equal @evnt_data['location']
      _(created['start_datetime']).must_equal @evnt_data['start_datetime']
      _(created['end_datetime']).must_equal @evnt_data['end_datetime']
      _(created['is_google']).must_equal @evnt_data['is_google']
      _(created['is_flexible']).must_equal @evnt_data['is_flexible']
    end

    it 'SAD: should not create new event without authorization' do
      post 'api/v1/events', @evnt_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create event with mass assignment' do
      bad_data = @evnt_data.clone
      bad_data['created_at'] = '1990-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/events', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
