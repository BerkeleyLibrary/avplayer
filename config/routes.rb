Rails.application.routes.draw do
  root to: (Rails.application.config.show_homepage ? 'player#index' : redirect('/404.html'))

  get '/:collection/:record_id', to: 'player#show', as: :player

  # Omniauth automatically handles requests to /auth/:provider. We need only
  # implement the callback.
  get '/login', to: 'sessions#new', as: :login
  get '/logout', to: 'sessions#destroy', as: :logout
  get '/auth/:provider/callback', to: 'sessions#callback', as: :omniauth_callback
  get '/auth/failure', to: 'sessions#failure'

  defaults format: 'json' do
    # TODO: separate HealthController
    get '/health', to: 'player#health'
  end

  # Expects query string: collection=<collection>&relative_path=<paths>, where
  # <paths> is a list of relative paths from the collection root, separated by
  # URL-encoded semicolons (%3B)
  get '/preview', to: 'player#preview' if Rails.application.config.allow_preview
end
