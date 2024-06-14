# frozen_string_literal: true

require 'date'

module No2Date
  class CalculateFreeTime
    def initialize(start_date, end_date, events_under_appointment)
      # @current_time = Time.now.in_time_zone('Asia/Taipei') 
      @start_date = start_date
      @end_date = end_date
      @all_events = events_under_appointment
    end

    def call
      events = parse_events(@all_events)
      free_times = find_free_times_for_range(@start_date, @end_date, events)
      free_times.each do |day_info|
        puts "Date: #{day_info[:day]}"
        day_info[:free_times].each do |free_time|
          puts "  Free from #{free_time[:start].strftime('%H:%M')} to #{free_time[:end].strftime('%H:%M')}"
        end
      end
      free_times
    end

    def parse_events(data)
      events = []
      data.each do |person, event_times|
        event_times.each do |time_pair|
          start_time, end_time = time_pair
          events << { start: DateTime.parse(start_time), end: DateTime.parse(end_time) }
        end
      end
      events
    end

    def merge_events(events)
      events.sort_by! { |event| event[:start] }
      merged_events = []
      events.each do |current_event|
        if merged_events.empty? || merged_events.last[:end] < current_event[:start]
          merged_events << current_event
        else
          merged_events.last[:end] = [merged_events.last[:end], current_event[:end]].max
        end
      end
      merged_events
    end

    def find_free_times(events, day_start, day_end)
      free_times = []
      last_end_time = day_start
      events.each do |event|
        if last_end_time < event[:start]
          free_times << { start: last_end_time, end: event[:start] }
        end
        last_end_time = event[:end]
      end

      if last_end_time < day_end
        free_times << { start: last_end_time, end: day_end }
      end

      free_times
    end

    def process_day(day, events)
      day_start = DateTime.parse("#{day}T00:00:00")
      day_end = DateTime.parse("#{day}T23:59:00")
      day_events = events.select do |event|
        event[:start] <= day_end && event[:end] >= day_start
      end
      merged_events = merge_events(day_events)
      find_free_times(merged_events, day_start, day_end)
    end

    def find_free_times_for_range(start_date, end_date, events)
      (Date.parse(start_date)..Date.parse(end_date)).map do |day|
        {
          day: day,
          free_times: process_day(day, events)
        }
      end
    end
  end
end
