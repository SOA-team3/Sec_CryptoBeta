require 'date'

class DateTime
  def beginning_of_day
    DateTime.new(year, month, day, 0, 0, 0, offset)
  end

  def end_of_day
    DateTime.new(year, month, day, 23, 59, 59, offset)
  end
end

def split_events_by_day(events)
  split_events = []

  events.each do |event|
    current_start = event[:start]
    while current_start < event[:end]
      day_start = current_start.beginning_of_day
      day_end = current_start.end_of_day

      split_events << {
        start: current_start,
        end: [event[:end], day_end].min
      }

      current_start = (day_end + (1.0 / 86400)).beginning_of_day
    end
  end

  split_events
end

# test
# events = [
#   { start: DateTime.parse('2024-06-20T03:43:00+08:00'), end: DateTime.parse('2024-06-20T05:54:00+08:00') },
#   { start: DateTime.parse('2024-06-18T03:54:00+08:00'), end: DateTime.parse('2024-06-19T03:54:00+08:00') },
#   { start: DateTime.parse('2024-06-20T17:55:00+08:00'), end: DateTime.parse('2024-06-25T03:55:00+08:00') },
#   { start: DateTime.parse('2024-06-22T17:31:00+08:00'), end: DateTime.parse('2024-06-22T19:31:00+08:00') }
# ]

# split_events = split_events_by_day(events)
# split_events.each do |event|
#   puts "Event: Start - #{event[:start]}, End - #{event[:end]}"
# end
