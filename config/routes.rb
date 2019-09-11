Rails.application.routes.draw do
  get '/' => 'player#index'

  get '/:collection/:files',
      to: 'player#index',
      format: false,
      defaults: { format: 'html' },
      constraints: { files: /.*/ }
end
