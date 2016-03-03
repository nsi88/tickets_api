module Citrus
  # XXX Citrus не понимает границы слов (\b)
  # Пока нет времени патчить добавлю пробелы в начало/конец строки
  module GrammarMethods
    alias_method :orig_parse, :parse

    def parse(source, options = {})
      orig_parse(' ' + source + ' ', options)
    end
  end
end

Citrus.load File.expand_path('../../../lib/grammars/cities', __FILE__)
