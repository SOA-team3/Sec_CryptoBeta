# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Meeting Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all meetings' do
    puts "meetings spec: #{DATA[:meetings][0]}"

    No2Date::Meeting.create(DATA[:meetings][0]).save
    No2Date::Meeting.create(DATA[:meetings][1]).save

    get 'api/v1/meetings'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single meeting' do
    existing_meet = DATA[:meetings][1]
    No2Date::Meeting.create(existing_meet).save
    id = No2Date::Meeting.first.id

    get "/api/v1/meetings/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['name']).must_equal existing_meet['name']
    _(result['data']['attributes']['description']).must_equal existing_meet['description']
    _(result['data']['attributes']['organizer']).must_equal existing_meet['organizer']
    _(result['data']['attributes']['attendees']).must_equal existing_meet['attendees']
  end

  it 'SAD: should return error if unknown meeting requested' do
    get '/api/v1/meetings/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new meetings' do
    existing_meet = DATA[:meetings][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/meetings', existing_meet.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.headers['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    meet = No2Date::Meeting.first

    _(created['id']).must_equal meet.id
    _(created['name']).must_equal existing_meet['name']
    _(created['description']).must_equal existing_meet['description']
    _(created['organizer']).must_equal existing_meet['organizer']
    _(created['attendees']).must_equal existing_meet['attendees']
  end
end
