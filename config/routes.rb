begin
  Rails.application.routes.draw do
    get '/:collection/:record_id', to: 'player#show'
    get '/health', to: 'player#health', format: false, defaults: { format: 'json' }
    root to: (Rails.application.config.show_homepage ? 'player#index' : redirect('/404.html'))

    # Expects query string: collection=<collection>&relative_path=<paths>, where
    # <paths> is a list of relative paths from the collection root, separated by
    # URL-encoded semicolons (%3B)
    get '/preview', to: 'player#preview' if Rails.application.config.allow_preview
  end
end
