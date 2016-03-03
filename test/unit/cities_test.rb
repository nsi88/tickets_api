require 'test_helper'
#
class CitiesTest < ActiveSupport::TestCase
  # TODO: Больше тестов
  def test_cities
    check 'из Бангкока в Доминику с 26 по 29 декабря вдвоём бизнес', :BKK, :DOM
    check 'Париж послезавтра', nil, :PAR
    check 'из Парижа в Лапенранту на выходные', :PAR, :LPP
    check 'Собираюсь в Париж из Москвы 23-го', :MOW, :PAR
    check 'Лечу 2-го питер 10-го москва', :LED, :MOW
    assert_raises(Citrus::ParseError) do
      check 'Орёл Тайланд 25-го марта', :ORL, :TAI
    end
    assert_raises(Citrus::ParseError) do
      check 'Шеф из Челябинска в Голивуд за сотку', :CHL, :HOL
    end
  end

  private

  # @param [String]
  # @param [String] iata-код города
  # @param [String] iata-код города
  def check(src, origin, destination)
    m = Cities.parse(src)
    assert_equal origin.to_s, m.capture(:origin).code,
                 "Wrong origin #{m.capture(:origin).code} for '#{src}'" if origin
    assert_equal destination.to_s, m.capture(:destination).code,
                 "Wrong destination #{m.capture(:destination).code} for '#{src}'"
  end
end
