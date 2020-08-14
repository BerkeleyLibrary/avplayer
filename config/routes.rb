begin
  Rails.application.routes.draw do
    get '/:collection/:record_id', to: 'player#show'
    get '/preview', to: 'player#preview' if Rails.application.config.allow_preview
    get '/health', to: 'player#health', format: false, defaults: { format: 'json' }
    root to: (Rails.application.config.show_homepage ? 'player#index' : redirect('/404.html'))
  end
end
