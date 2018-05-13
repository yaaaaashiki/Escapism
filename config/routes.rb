Rails.application.routes.draw do
  root 'introductions#index'

  get 'rooms/show' => 'rooms#show'
  get 'login' => 'sessions#new'
  get 'logout' => 'sessions#destroy'

  get 'thesis/download/:id' => 'theses#download', :as => :download
  get 'users/new/:token' => 'users#new'
  get 'recommendations' => 'recommendations#index'

  namespace :admin do
    get '/' => 'dashboard#index'
    get '/sign_in' => 'sessions#new'
    post '/sign_in' => 'sessions#create'
    get '/sign_out' => 'sessions#destroy'
    resources :users, only: [:index, :new, :show, :create, :update]
    resources :theses, only: [:index, :new, :show, :create, :update]
    resources :passwords, only: [:index, :new, :show, :update]
    resources :labos, only: [:index, :new, :show, :update]
  end

  resources :theses, only: [:show, :index] do
    resources :comments, only: [:create]
  end

  resources :sessions, only: [:create]
  resources :mail_addresses, only: [:index, :new, :create]
  resources :users, only: [:index, :new, :create]
  resources :ciniis, only: [:index, :show]

  get '*path', controller: 'application', action: 'render_404'
end
