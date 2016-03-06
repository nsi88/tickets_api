require 'test_helper'
#
class DatesTest < ActiveSupport::TestCase
  def setup
    Date.stubs(:today).returns(Date.new(2016, 02, 20))
  end

  def test_dates
    check 'из Бангкока в Доминику с 26 по 29 декабря вдвоём бизнес', '26.12', '29.12'
    check 'Париж послезавтра', '22.02'
    check 'из Парижа в Лапенранту на выходные', '26.02', '28.02'
    check 'С 3 марта 2147 по 30 апреля 2148 года', '03.03.2147', '30.04.2148'
    check 'Летим 23 12', '23.12'
    check 'из Парижа в Лапенранту на выходной', '21.02'
    check 'Хочу после послезавтра в Москву', '23.02'
    check 'Хочу послезавтра в Москву', '22.02'
    check 'Хочу завтра в Москву', '21.02'
    check 'Хочу сегодня в Москву', '20.02'
    assert_raises(Citrus::ParseError) do
      check 'Хочу сейчас в Москву', '20.02'
    end
    check 'Через 7 дней на Майорку', '28.02'
    check 'В пятницу в Питер', '26.02'
    check 'Со среды на воскресенье праздновал ДР', '24.02'
    Date.stubs(:today).returns(Date.new(2016, 02, 21))
    check 'из Парижа в Лапенранту на выходной', '27.02'
  end

  def test_actual_date
    check '1', '1.03'
    check '19', '19.03'
    check '20', '20.03'
    check '21', '21.02'
    Date.stubs(:today).returns(Date.new(2016, 12, 31))
    check '1', '01.01.2017'
  end

  def test_actual_period
    # Считаем, что сегодня уже не успеть (хотя и не уверен как правильней)
    check 'с 20 по 25', '20.03', '25.03'
    check 'с 23 по 25', '23.02', '25.02'
    check '15 20', '15.03', '20.03'

    check 'с 25 по 20', '25.02', '20.03'
    check 'с 25 по 23', '25.02', '23.03'
    check '20 15', '20.03', '15.04'

    check 'с 1 по 10 мая', '01.05', '10.05'
    check 'с 1 мая по 10', '01.05', '10.05'

    check 'с 15 по 10 февраля', '15.03.2016', '10.02.2017'
    assert_raises ArgumentError do
      check 'с 15 февраля по 10 февраля', '15.02', '10.02'
    end

    Date.stubs(:today).returns(Date.new(2016, 12, 31))
    check 'с 20 по 10', '20.01.2017', '10.02.2017'
  end

  private

  def check(src, *dates)
    dates.map! { |date| Date.parse(date + '.' + Date.today.year.to_s) }
    assert_equal dates, Dates.parse(src).value,
                 "Wrong dates: #{dates} for '#{src}'"
  end
end
