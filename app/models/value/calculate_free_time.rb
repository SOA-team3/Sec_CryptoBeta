# frozen_string_literal: true

require 'date'
require 'time'
require 'tzinfo'

module No2Date
  class CalculateFreeTime
    def initialize(start_date, end_date, events_under_appointment)
      time_zone = 'Asia/Taipei'
      time_now = Time.now.getlocal(TZInfo::Timezone.get(time_zone).current_period.offset.utc_total_offset)
      intervals = 6
      unformatted_end_date = time_now + intervals * 24 * 60 * 60
      @start_date  = time_now.strftime('%Y-%m-%d')
      @end_date = unformatted_end_date.strftime('%Y-%m-%d')
      @all_events = events_under_appointment
    end

    def call
      events = parse_events(@all_events)
      free_times = find_free_times_for_range(@start_date, @end_date, events)
      puts "start_date: #{@start_date}"
      puts "end_date: #{@end_date}"
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
          event_time = { start: DateTime.parse(start_time), end: DateTime.parse(end_time) }
          # puts "parse_events: #{event_time}"
          events << event_time
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
      # puts "process_day day: #{day}"
      # puts "process_day events: #{events}"

      # Convert UTC time to +08:00 timezone
      day_start = DateTime.parse("#{day}T00:00:00+08:00")
      day_end = DateTime.parse("#{day}T23:59:00+08:00")
      # puts "process_day day_start: #{day_start}"
      # puts "process_day day_end: #{day_end}"

      day_events = events.select do |event|
        event[:start] <= day_end && event[:end] >= day_start
      end
      # puts "process_day day_events: #{day_events}"

      merged_events = merge_events(day_events)
      # puts "process_day merged_events: #{merged_events}"
      # puts "\n"

      find_free_times(merged_events, day_start, day_end)
    end

    def find_free_times_for_range(start_date, end_date, events)
      (Date.parse(start_date)..(Date.parse(end_date)+1)).map do |day|
        {
          day: day,
          free_times: process_day(day, events)
        }
      end
    end

  end
end
