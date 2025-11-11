Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users, path: "auth"

  mount RailsWorkflow::Engine => "/workflow"

  resources :operations, only: [:show] do
    post :complete, on: :member
    post :skip, on: :member
    post :cancel, on: :member
  end

  resources :users, only: [:index, :show]

  root "users#index"
end
