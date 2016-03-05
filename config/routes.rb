Rails.application.routes.draw do
  get '/search_options' => 'application#search_options'
  get '/docs' => 'docs#index'
end
