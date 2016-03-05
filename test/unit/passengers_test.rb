require 'test_helper'
#
class PassengersTest < ActiveSupport::TestCase
  def test_passengers
    check 'из Бангкока в Доминику с 26 по 29 декабря вдвоём бизнес', 2
    assert_raises(Citrus::ParseError) do
      check 'Париж послезавтра'
    end
    assert_raises(Citrus::ParseError) do
      check 'из Парижа в Лапенранту на выходные'
    end
    check 'На выходные втроём', 3
    check 'Нас четверо младенцев', 0, 0, 4
    check 'Впятером', 5
    check 'шестеро детей', 0, 6
    check 'всемером', 7
    check 'ввосьмером', 8
    check 'вдевятером', 9
    check 'вдесятером', 10
    assert_raises(Citrus::ParseError) do
      check 'водиннадцатером', 11
    end
    check 'Послезавтра в Париж 1 ребёнок и двое взрослых', 2, 1
    check '1 Взрослый двое младенцев', 1, 0, 2
    check 'Билеты для 3 пассажиров бизнес', 3
  end

  private

  def check(src, *counts)
    roots = [:adults, :children, :infants]
    counts[0] ||= 1
    counts[1] ||= 0
    counts[2] ||= 0
    Hash[*roots.zip(counts).flatten].each do |root, count|
      next if count == 0
      res = Passengers.parse(src, root: root).value
      assert_equal count, res, "Wrong passengers count #{res} for '#{src}'"
    end
  end
end
