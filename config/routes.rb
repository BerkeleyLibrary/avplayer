Rails.application.routes.draw do
  get '/',
      to: 'player#index',
      as: :root

  get '/:collection/:files',
      to: 'player#show',
      as: 'show',
      format: false,
      defaults: { format: 'html' },
      constraints: { files: /.*/ }

  get '/health', to: 'player#health', format: false, defaults: { format: 'json' }
end
