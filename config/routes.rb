Rails.application.routes.draw do
  root 'introductions#index'

  get 'login' => 'sessions#new'
  get 'logout' => 'sessions#destroy'

  get 'thesis/download/:id' => 'theses#download', :as => :download
  get 'users/new/:token' => 'users#new'
  get 'visual' => 'visual#index'
  get 'recommendations' => 'recommendations#index'

  namespace :admin do
    get '/' => 'dashboard#index'
    get '/sign_in' => 'sessions#new'
    post '/sign_in' => 'sessions#create'
    get '/sign_out' => 'sessions#destroy'
    resources :users, only: [:index, :new, :create, :update]
    resources :theses, only: [:index, :update]
  end

  resources :theses, only: [:show, :index] do
    resources :comments, only: [:create]
  end

  resources :sessions, only: [:create]
  resources :mails, only: [:new, :create]
  resources :users, only: [:new, :index, :create]
end
