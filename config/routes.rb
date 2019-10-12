Rails.application.routes.draw do
  get '/',
      to: 'player#index',
      as: :root

  # TODO: don't end with .mp3/.mp4, so Safari doesn't get confused
  get '/:collection/:paths',
      to: 'player#show',
      as: 'show',
      format: false,
      defaults: { format: 'html' },
      constraints: { paths: /.*/ }

  get '/health', to: 'player#health', format: false, defaults: { format: 'json' }
end
