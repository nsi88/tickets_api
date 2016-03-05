#
class ApplicationController < ActionController::API
  def search_options
    return render_error('Missing param q') if params[:q].blank?
    render json: {
      search_options: {
        passengers: passengers,
        segments: segments,
        trip_class: trip_class
      }
    }
  rescue Citrus::ParseError => e
    Rails.logger.error e.message
    Rails.logger.info "Cannot parse '#{params[:q]}'"
    render_error('Invalid param q')
  end

  private

  def render_error(message, code = 400)
    render json: { error: { code: code, message: message } }
  end

  def passengers
    {
      adults: adults,
      children: children,
      infants: infants
    }
  end

  def adults
    Passengers.parse(params[:q], root: :adults).value
  rescue Citrus::ParseError
    1
  end

  def children
    Passengers.parse(params[:q], root: :children).value
  rescue Citrus::ParseError
    0
  end

  def infants
    Passengers.parse(params[:q], root: :infants).value
  rescue Citrus::ParseError
    0
  end

  # FIXME: Возможен поиск из Питера в Питер
  def segments
    cities = Cities.parse(params[:q])
    origin = cities.origin.try(:code) || 'LED'
    destination = cities.destination.code
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
