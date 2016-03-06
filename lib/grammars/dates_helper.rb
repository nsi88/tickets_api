# Used by dates grammar
module DatesHelper
  # Returns a future date if month or year are skipped
  def actual_date(day, month = nil, year = nil)
    date = Date.new(year || Date.today.year, month || Date.today.month, day)

    if date <= Date.today && !month
      date = Date.new(date.year, Date.today.next_month.month, date.day)
    end

    if date <= Date.today && !year
      date = Date.new(Date.today.next_year.year, date.month, date.day)
    end

    date
  end

  # Tries to make future period with finish > start
  #
  # @param [Array] Day, month, year numbers of start
  # @param [Array] Day, month, year numbers of finish
  # @return [Array] Array of dates
  # @raise [ArgumentError] If start > finish
  def actual_period(start_dmy, finish_dmy)
    if start_dmy[0] < finish_dmy[0]
      dates = [
        actual_date(start_dmy[0], start_dmy[1] || finish_dmy[1],
                    start_dmy[2] || finish_dmy[2]),
        actual_date(finish_dmy[0], finish_dmy[1] || start_dmy[1],
                    finish_dmy[2] || start_dmy[2])
      ]
    else
      dates = [actual_date(*start_dmy), actual_date(*finish_dmy)]
    end

    if dates[0] > dates[1] && !finish_dmy[1]
      dates[1] = Date.new(dates[1].year, dates[1].next_month.month, dates[1].day)
    end

    if dates[0] > dates[1] && !finish_dmy[1]
      dates[1] = Date.new(dates[1].next_year.year, dates[1].month, date[1].day)
    end

    fail ArgumentError, 'Invalid period' if dates[0] > dates[1]

    dates
  end

  # @param [Fixnum] See Date#wday
  def near_wday(wday)
    diff = wday - Date.today.wday
    diff += 7 if diff <= 0
    Date.today + diff.days
  end
end
