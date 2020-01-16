begin
  Rails.application.routes.draw do
    get '/:collection/:record_id', to: 'player#show'

    get '/health', to: 'player#health', format: false, defaults: { format: 'json' }

    if Rails.application.config.show_homepage
      root to: 'player#index'
    else
      root to: redirect('/404.html')
    end
  end
end
