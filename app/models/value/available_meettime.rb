# frozen_string_literal: true

module No2Date
  module Value
    # Get Available Meet Time
    class Available_MeetTime
      # Numebers of attendees required to retrieve from the room?
      ATTENDEES = 3

      def initialize(attendees_scheds, week)
        @attendees_scheds = attendees_scheds
        @week = week
      end

      # week would be an array of date
      # e.g ['2024-05-01', '2024-05-02'..]
      def get_available_meettimes(attendees_scheds, week)
        available_meettimes = []
        week.each do |date|
          times = overlapped_times(attendees_scheds, date)
          available_meettimes.push(times)
        end

        # available_meettimes would be an 2d array, each small array refers to 7 days;
        # each small array can be empty or contains hashes of datetimes of available meet time
        # empty array stands for no overlapped time
        # e.g. [[{'start_datetime': '09:00:00', 'end_datetime': '10:00:00'},
        # {'start_datetime': '19:30:00', 'end_datetime': '21:15:00'}],
        # [], [], [], [], [], []]
        available_meettimes
      end

      def get_attendees_schedules_by_date(attendees_scheds, date)
        # get attendees' schedules with the same date from db
        # attendees_scheds would be a hash-array of all attendees' schedules
        # date, e.g: '2024-05-01', need to consider crossing days

        # some code...

        attendees_scheds_by_date
      end

      # Find overlapped schedules in one specific date
      def overlapped_times(attendees_scheds, date, majortiy_meet = true)
        overlapped_times = []
        get_attendees_schedules_by_date(attendees_scheds, date)
        overlap_counts = 0

        # some code...

        #  return ideal overlapped times (all are available)
        return overlapped_times if (overlap_counts + 1) == ATTENDEES

        # some code...

        # temp removed
        # flexible_overlapped_times = flexible_adjustment
        # if flexible_overlapped_times != overlapped_times
        #   flexible_overlapped_times
        # elsif majortiy_meet == true
        #   majority_meet(overlap_counts)
        # else
        #   overlapped_times
        # end
      end

      # Consider the case of no available meetime for total overlapping
      # Create a majority vote that at least n attendees overlap the available meetime
      def majority_meet(n)
        # some code...
        majority_overlapped_time
      end

      # Some code about check the is_flexible in attendees_scheds and make(unblock) them able to overlap
      def flexible_adjustment(attendees_scheds)
        # some code...
        flexible_overlapped_times
      end
    end
  end
end

# Test the module
attendees_scheds = {
  "ella" => [
    ["2024-04-19 09:00:00 +0800", "2024-04-19 10:00:00 +0800"],
    ["2024-04-20 09:00:00 +0800", "2024-04-20 10:00:00 +0800"]
  ],
  "brian" => [
    ["2024-04-19 09:00:00 +0800", "2024-04-19 10:00:00 +0800"],
    ["2024-04-20 09:00:00 +0800", "2024-04-20 10:00:00 +0800"]
  ],
  "adrian" => [
    ["2024-04-19 09:00:00 +0800", "2024-04-19 10:00:00 +0800"],
    ["2024-04-20 09:00:00 +0800", "2024-04-20 10:00:00 +0800"]
  ]
}
week = ['2024-04-19', '2024-04-20'...]
meettime = No2Date::Value::Available_MeetTime.new(attendees_scheds, week)
puts meettime
