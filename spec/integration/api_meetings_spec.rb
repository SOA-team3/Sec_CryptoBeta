# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Meeting Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = No2Date::Account.create(@account_data)
    @wrong_account = No2Date::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting Meetings' do
    describe 'Getting list of meetings' do
      before do
        @account.add_owned_meeting(DATA[:meetings][0])
        @account.add_owned_meeting(DATA[:meetings][1])
      end

      it 'HAPPY: should get list for authorized account' do
        # auth = No2Date::AuthenticateAccount.call(
        #   username: @account_data['username'],
        #   password: @account_data['password']
        # )

        header 'AUTHORIZATION', auth_header(@account_data)
        get 'api/v1/meetings'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process without authorization' do
        get 'api/v1/meetings'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    # it 'HAPPY: should be able to get list of all meetings' do
    #   No2Date::Meeting.create(DATA[:meetings][0])
    #   No2Date::Meeting.create(DATA[:meetings][1])

    #   get 'api/v1/meetings'
    #   _(last_response.status).must_equal 200

    #   result = JSON.parse last_response.body
    #   _(result['data'].count).must_equal 2
    # end

    it 'HAPPY: should be able to get details of a single meeting' do
      meet = @account.add_owned_meeting(DATA[:meetings][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/meetings/#{meet.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal meet.id
      _(result['attributes']['name']).must_equal meet.name
      _(result['attributes']['description']).must_equal meet.description
      _(result['attributes']['organizer']).must_equal meet.organizer
      _(result['attributes']['attendees']).must_equal meet.attendees
    end

    it 'SAD: should return error if unknown meeting requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/meetings/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get meeting with wrong authorization' do
      meet = @account.add_owned_meeting(DATA[:meetings][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/meetings/#{meet.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of IDs' do
      @account.add_owned_meeting(DATA[:meetings][0])
      @account.add_owned_meeting(DATA[:meetings][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/meetings/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Meetings' do
    before do
      @meet_data = DATA[:meetings][1]
    end

    it 'HAPPY: should be able to create new meetings' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/meetings', @meet_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      meet = No2Date::Meeting.first

      _(created['id']).must_equal meet.id
      _(created['name']).must_equal @meet_data['name']
      _(created['description']).must_equal @meet_data['description']
      _(created['organizer']).must_equal @meet_data['organizer']
      _(created['attendees']).must_equal @meet_data['attendees']
    end

    it 'SAD: should not create new meeting without authorization' do
      post 'api/v1/meetings', @meet_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create meeting with mass assignment' do
      bad_data = @meet_data.clone
      bad_data['created_at'] = '1990-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/meetings', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
