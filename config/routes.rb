Rails.application.routes.draw do
  # RESTful Web Service (Resource API)
  get '/contributions' => 'contributions#index'
  get '/contributions/ask' => 'contributions#ask'
  get '/contributions/newest' => 'contributions#newest'
  get '/contributions/new' => 'contributions#new'
  get '/contributions/:id' => 'contributions#show'
  post '/contributions' => 'contributions#create'
  
  get '/users/:id' => 'users#show'
  put '/users/:id' => 'users#update'
  
  get '/comments' => 'comments#index'
  post '/comments' => 'comments#create'
  
  post '/replies' => 'replies#create'
  
  post '/votes' => 'votes#create'
  delete '/votes/:id' => 'votes#destroy'
  
  resources :votes
  
  resources :replies do
    #resources :replies
    put 'point', on: :member
    put 'unvote', on: :member
  end
  
  resources :comments do
    #resources :replies
    put 'point', on: :member
    put 'unvote', on: :member
  end
  
  resources :users 
  
  get '/auth/:provider/callback' => 'sessions#omniauth'
  get 'logout' => 'sessions#destroy'
  
  resources :contributions do
    #resources :comments
    collection do
      get 'newest'
      get 'ask'
    end
    put 'point', on: :member
    put 'unvote', on: :member
    post 'comment', on: :member
  end
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'contributions#index'
end
