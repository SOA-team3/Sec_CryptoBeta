# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module Calender
  STORE_DIR = 'app/db/store'

  # Holds a full secret event
  class Event
    # Create a new event by passing in hash of attributes
    def initialize(new_event)
      @id = new_event['id'] || new_id
      @title = new_event['title']
      @description = new_event['description']
      @location     = new_event['location']
      @start_date   = new_event['start_date']
      @start_datetime = new_event['start_datetime']
      @end_date = new_event['end_date']
      @end_dateime = new_event['end_datetime']
      @organizer    = new_event['organizer']
      @attendees    = new_event['attendees']
    end

    attr_reader :id, :filename, :description, :location, :start_date, :start_datetime, :end_date, :end_datetime,
                :organizer, :attendees
                
    #represent a resource object as json
    def to_json(options = {})
      JSON(
        {
          type: 'event', id:, filename:, description:, location:, start_date:, start_datetime:,
          end_date:, end_datetime:, organizer:, attendees:
        },
        options
      )
    end

    # File store must be setup once when application runs
    def self.setup
      FileUtils.mkdir_p(Calender::STORE_DIR)
    end

    # Stores event in file store
    def save
      File.write("#{Calender::STORE_DIR}/#{id}.txt", to_json)
    end

    # Query method to find one event
    def self.find(find_id)
      event_file = File.read("#{Calender::STORE_DIR}/#{find_id}.txt")
      Event.new JSON.parse(event_file)
    end

    # Query method to retrieve index of all events
    def self.all
      Dir.glob("#{Calender::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(Calender::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private
    # create unique IDs for new objects
    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
