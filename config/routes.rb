Rails.application.routes.draw do
  root 'pages#home'
  get 'pages/home', to: 'pages#home'

  resources :recipes do
    resources :comments, only: [:create]
  end
  resources :ingredients, except: [:destroy]

  get '/signup', to: 'chefs#new'

  resources :chefs, except: [:new]

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  mount ActionCable.server => '/cable'
end
