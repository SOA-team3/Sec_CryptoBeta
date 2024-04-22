# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app/controllers/app'
require_relative '../app/models/calendar_doc'

def app
  Calendar::Api
end

DATA = YAML.safe_load_file('app/db/seeds/event_seeds.yml')
puts DATA[1]

describe 'Test Calendar Web API' do
  include Rack::Test::Methods

  before do
    # Wipe database before each test
    Dir.glob("#{Calendar::STORE_DIR}/*.txt").each { |filename| FileUtils.rm(filename) }
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'Handle events' do
    it 'HAPPY: should be able to get list of all events' do
      Calendar::Event.new(DATA[0]).save
      Calendar::Event.new(DATA[1]).save

      get 'api/v1/calendars'
      result = JSON.parse last_response.body
      puts result
      _(result['event_ids'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single event' do
      Calendar::Event.new(DATA[1]).save
      id = Dir.glob("#{Calendar::STORE_DIR}/*.txt").first.split(%r{[/.]})[3]

      get "/api/v1/calendars/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    it 'SAD: should return error if unknown event requested' do
      get '/api/v1/calendars/foobar'

      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new events' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/calendars', DATA[1].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end
end
