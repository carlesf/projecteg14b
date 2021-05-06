Rails.application.routes.draw do
  # RESTful Web Service (Resource API)
  get '/contributions' => 'contributions#index'
  
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
