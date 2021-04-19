Rails.application.routes.draw do
  resources :users 
  get '/auth/:provider/callback' => 'sessions#omniauth'
  get 'logout' => 'sessions#destroy'
  

  resources :contributions do
    collection do
      get 'newest'
      get 'ask'
    end
    put 'point', on: :member
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'contributions#index'
end
