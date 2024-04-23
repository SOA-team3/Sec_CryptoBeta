# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test event Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:calendars].each do |calendar_data|
      No2Date::Calendar.create(calendar_data)
    end
  end

  it 'HAPPY: should be able to get list of all events' do
    calendar = No2Date::Calendar.first
    DATA[:events].each do |event|
      calendar.add_event(event)
    end

    get "api/v1/calendars/#{calendar.id}/events"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single event' do
    event_data = DATA[:events][1]
    calendar = No2Date::Calendar.first
    event = calendar.add_event(event_data).save

    get "/api/v1/calendars/#{calendar.id}/events/#{event.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal event.id
    _(result['data']['attributes']['title']).must_equal event_data['title']
    _(result['data']['attributes']['description']).must_equal event_data['description']
    _(result['data']['attributes']['location']).must_equal event_data['location']
    _(result['data']['attributes']['start_date']).must_equal event_data['start_date']
    _(result['data']['attributes']['start_datetime']).must_equal event_data['start_datetime']
    _(result['data']['attributes']['end_date']).must_equal event_data['end_date']
    _(result['data']['attributes']['end_datetime']).must_equal event_data['end_datetime']
    _(result['data']['attributes']['organizer']).must_equal event_data['organizer']
    _(result['data']['attributes']['attendees']).must_equal event_data['attendees']
  end

  it 'SAD: should return error if unknown event requested' do
    calendar = No2Date::Calendar.first
    get "/api/v1/calendars/#{calendar.id}/events/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new events' do
    calendar = No2Date::Calendar.first
    event_data = DATA[:events][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/calendars/#{calendar.id}/events",
         event_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.headers['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    event = No2Date.event.first

    _(created['id']).must_equal event.id
    _(result['data']['attributes']['title']).must_equal event_data['title']
    _(result['data']['attributes']['description']).must_equal event_data['description']
    _(result['data']['attributes']['location']).must_equal event_data['location']
    _(result['data']['attributes']['start_date']).must_equal event_data['start_date']
    _(result['data']['attributes']['start_datetime']).must_equal event_data['start_datetime']
    _(result['data']['attributes']['end_date']).must_equal event_data['end_date']
    _(result['data']['attributes']['end_datetime']).must_equal event_data['end_datetime']
    _(result['data']['attributes']['organizer']).must_equal event_data['organizer']
    _(result['data']['attributes']['attendees']).must_equal event_data['attendees']
  end
end
