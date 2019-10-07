Rails.application.routes.draw do
  get '/' => 'player#index'

  get '/:collection/:files',
      to: 'player#show',
      format: false,
      defaults: {format: 'html'},
      constraints: {files: /.*/}

  get '/health', to: 'player#health', format: false, defaults: {format: 'json'}
end
