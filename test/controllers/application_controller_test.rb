require 'test_helper'
#
class ApplicationControllerTest < ActionController::TestCase
  def test_search_options
    Date.stubs(:today).returns(Date.new(2016, 02, 20))
    invalid_param_error = '{"error":{"code":400,"message":"Invalid parameter q"}}'

    get :search_options
    assert_equal '{"error":{"code":400,"message":"Missing parameter q"}}', response.body

    get :search_options, q: 'boolshit'
    assert_equal invalid_param_error, response.body

    get :search_options, q: 'из Бангкока в Доминику с 26 по 29 декабря вдвоём бизнес'
    # Тут у меня не сходится картина мира. В задании для этой строки
    # {"search_options": {"passengers": {"adults": 2, "children": 0, "infants": 0}, "segments": [{"date": "2016-12-26", "destination": "BKK", "origin": "DOM"},{"date": "2016-12-29", "destination": "DOM", "origin": "BKK"}], "trip_class": "C"}}
    # Т.е. летим из Доминики 26-го?
    # Сделал чтобы Бангкок для это случая считался первым origin-ом
    # Если надо переделаю
    assert_equal JSON.parse('{"search_options": {"passengers": {"adults": 2, "children": 0, "infants": 0}, "segments": [{"date": "2016-12-26", "destination": "DOM", "origin": "BKK"},{"date": "2016-12-29", "destination": "BKK", "origin": "DOM"}], "trip_class": "C"}}'), JSON.parse(response.body)

    get :search_options, q: 'Париж послезавтра'
    assert_equal JSON.parse('{"search_options": {"segments": [{"date": "2016-02-22", "origin": "LED", "destination": "PAR"}], "trip_class": "Y", "passengers": {"adults": 1, "children": 0, "infants": 0}}}'), JSON.parse(response.body)

    get :search_options, q: 'из Парижа в Лапенранту на выходные'
    assert_equal JSON.parse('{"search_options": {"segments": [{"date": "2016-02-26", "origin": "PAR", "destination": "LPP"}, {"date": "2016-02-28", "origin": "LPP", "destination": "PAR"}], "passengers": {"children": 0, "adults": 1, "infants": 0}, "trip_class": "Y"}}'), JSON.parse(response.body)

    get :search_options, q: 'В Питер 23-го'
    assert_equal invalid_param_error, response.body

    get :search_options, q: '12 пассажиров 13 декабря летят в москву'
    assert_equal JSON.parse('{"search_options":{"passengers":{"adults":12,"children":0,"infants":0},"segments":[{"date":"2016-12-13","origin":"LED","destination":"MOW"}],"trip_class":"Y"}}'), JSON.parse(response.body)
  end
end
