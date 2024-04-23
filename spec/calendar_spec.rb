# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Calendar Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all calendars' do
    No2Date::Calendar.create(DATA[:calendars][0]).save
    No2Date::Calendar.create(DATA[:calendars][1]).save

    get 'api/v1/calendars'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single calendar' do
    existing_calendar = DATA[:calendars][1]
    No2Date::Calendar.create(existing_calendar).save
    id = No2Date::Calendar.first.id

    get "/api/v1/calendars/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['name']).must_equal existing_calendar['name']
    _(result['data']['attributes']['url']).must_equal existing_calendar['url']
    _(result['data']['attributes']['owner']).must_equal existing_calendar['owner']
  end

  it 'SAD: should return error if unknown calendar requested' do
    get '/api/v1/calendars/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new calendars' do
    existing_calendar = DATA[:calendars][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/calendars', existing_calendar.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.headers['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    calendar = No2Date::Calendar.first

    _(created['id']).must_equal calendar.id
    _(created['name']).must_equal existing_calendar['name']
    _(created['repo_url']).must_equal existing_calendar['repo_url']
  end
end