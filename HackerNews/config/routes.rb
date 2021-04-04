Rails.application.routes.draw do
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
