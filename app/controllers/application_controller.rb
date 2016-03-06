#
class ApplicationController < ActionController::API
  include Swagger::Blocks

  swagger_path '/search_options' do
    operation :get do
      key :summary, 'Search Options'
      parameter do
        key :name, :q
        key :in, :query
        key :description, 'Строка ввода голосового поиска'
        key :required, true
        key :type, :string
      end
      key :tags, %w(SearchOptions)
      response 200 do
        key :description, 'Параметры для API поиска авиабилетов'
        schema do
          key :'$ref', :SearchOptions
        end
      end
      response :default do
        key :description, 'Invalid parameter error'
        schema do
          key :'$ref', :Error
        end
      end
    end
  end

  swagger_schema :SearchOptions do
    key :type, :object
    property :search_options do
      key :type, :object
      # NOTE: swagger-blocks ещё не поддерживает ссылку внутри property на другую
      # схему. Хотя внутри items поддерживает
      property :passengers do
        key :type, :object
        property :adults do
          key :type, :integer
          key :default, 1
        end
        property :children do
          key :type, :integer
        end
        property :infants do
          key :type, :integer
        end
      end
      property :segments do
        key :type, :array
        items do
          key :'$ref', :Segment
        end
      end
      property :trip_class do
        key :type, :string
        key :description, 'Возможные классы обслуживания. Эконом Y, бизнес C'
        key :default, 'Y'
      end
    end
  end

  def search_options
    return render_error('Missing parameter q') if params[:q].blank?
    render json: {
      search_options: {
        # NOTE: удаляем найденную информацию о пассажирах из строки поиска
        # во избежание конфликтов с датой
        passengers: extract_passengers,
        segments: segments,
        trip_class: trip_class
      }
    }
  rescue Citrus::ParseError, ArgumentError => e
    Rails.logger.error e.message
    Rails.logger.info "Cannot parse '#{params[:q]}'"
    render_error('Invalid parameter q')
  end

  private

  swagger_schema :Error do
    key :type, :object
    property :error do
      key :type, :object
      property :code do
        key :type, :integer
        key :default, 400
      end
      property :message do
        key :type, :string
        key :default, 'Invalid parameter q'
      end
    end
  end

  def render_error(message, code = 400)
    render json: { error: { code: code, message: message } }
  end

  def extract_passengers
    {
      adults: extract_adults,
      children: extract_children,
      infants: extract_infants
    }
  end

  def extract_adults
    m = Passengers.parse(params[:q], root: :adults)
    params[:q].gsub!(m.to_str.strip, '')
    m.value
  rescue Citrus::ParseError
    1
  end

  def extract_children
    m = Passengers.parse(params[:q], root: :children)
    params[:q].gsub!(m.to_str.strip, '')
    m.value
  rescue Citrus::ParseError
    0
  end

  def extract_infants
    m = Passengers.parse(params[:q], root: :infants)
    params[:q].gsub!(m.to_str.strip, '')
    m.value
  rescue Citrus::ParseError
    0
  end

  swagger_schema :Segment do
    key :type, :object
    property :date do
      key :type, :string
      key :format, :date
      key :description, 'Дата отправления'
    end
    property :origin do
      key :type, :string
      key :format, :iata
      key :description, 'Код города отправления'
    end
    property :destination do
      key :type, :string
      key :format, :iata
      key :description, 'Код города назначения'
    end
  end

  def segments
    cities = Cities.parse(params[:q])
    origin = cities.origin.try(:code) || 'LED'
    destination = cities.destination.code
    fail ArgumentError, "Origin == destination == #{origin}" if origin == destination
    begin
      dates = Dates.parse(params[:q]).value
    rescue Citrus::ParseError, ArgumentError
      dates = [Date.tomorrow]
    end
    res = [{ date: dates[0], origin: origin, destination: destination }]
    res << { date: dates[1], origin: destination, destination: origin } if dates[1]
    res
  end

  def trip_class
    TripClass.parse(params[:q]).value
  rescue Citrus::ParseError
    'Y'
  end
end
