require 'test_helper'
#
class DatesTest < ActiveSupport::TestCase
  def test_dates
    Date.stubs(:today).returns(Date.new(2016, 02, 20))
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

  private

  def check(src, *dates)
    dates.map! { |date| Date.parse(date + '.' + Date.today.year.to_s) }
    assert_equal dates, Dates.parse(src).value,
                 "Wrong dates: #{dates} for '#{src}'"
  end
end
