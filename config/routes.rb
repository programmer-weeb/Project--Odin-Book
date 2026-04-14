Rails.application.routes.draw do
  devise_for :users
  root "posts#index"

  # Shallow nesting keeps URLs like /comments/1 instead of /posts/1/comments/1
  resources :posts, shallow: true do
    resources :comments, only: [ :create, :destroy ]
    resources :likes, only: [ :create, :destroy ]
  end

  resources :users, only: [ :index, :show ] do
    # Nested for the context of "who" I am following
    resources :follow_requests, only: [ :create ]

    # Optional: see a specific user's friends
    get "friends", on: :member
  end

  # Management of my own interactions
  resources :follow_requests, only: [:index, :destroy] do
    member do
      patch :accept
      patch :reject
    end
    collection do
      get :received
      get :sent
    end
  end

  # Current User's Profile
  resource :profile, only: [ :edit, :update ]

  get "up" => "rails/health#show", as: :rails_health_check
end
