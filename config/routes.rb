Rails.application.routes.draw do
  resources :companies, only: [] do
    resources :shipments, only: [:show]
  end
  resources :shipments, only: [:index, :show]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end