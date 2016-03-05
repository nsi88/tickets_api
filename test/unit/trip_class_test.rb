require 'test_helper'
#
class TripClassTest < ActiveSupport::TestCase
  def test_trip_class
    assert_equal 'C', TripClass.parse('из Бангкока в Доминику с 26 по 29 декабря вдвоём бизнес').value
    assert_equal 'Y', TripClass.parse('Эконом класс в USA').value
  end
end
