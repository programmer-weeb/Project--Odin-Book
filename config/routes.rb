Rails.application.routes.draw do
  get "profiles/edit"
  get "profiles/update"
  get "follow_requests/index"
  get "follow_requests/destroy"
  get "follow_requests/accept"
  get "follow_requests/reject"
  get "follow_requests/received"
  get "follow_requests/sent"
  get "follow_requests/create"
  get "users/index"
  get "users/show"
  get "users/friends"
  get "likes/create"
  get "likes/destroy"
  get "comments/create"
  get "comments/destroy"
  get "posts/index"
  get "posts/show"
  get "posts/new"
  get "posts/create"
  get "posts/edit"
  get "posts/update"
  get "posts/destroy"
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
