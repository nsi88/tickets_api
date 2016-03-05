class DocsController < ApplicationController
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '0.1.0'
      key :title, 'Tickets API'
      key :description, 'API, преобразующее строку ввода голосового поиска ' \
                        'в параметры, пригодные для использования при ' \
                        'взаимодействии с API поиска авиабилетов'
    end
    key :host, CONFIG[:host]
    key :schemes, %w(http)
    key :produces, %w(application/json)
  end

  SWAGGERED_CLASSES = [
    ApplicationController,
    self
  ]

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end
