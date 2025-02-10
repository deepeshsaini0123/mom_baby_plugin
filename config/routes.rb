# frozen_string_literal: true
Discourse::Application.routes.append do
  # Admin User Api's
  post "/create_admin_user" => "admin_user#create_admin_user"
  post "/create_new_user" => "admin_user#create_new_user"
  get "/list_admin_user" => "admin_user#list_admin_user"


  scope :mom_verse do
    resources :follow, only: [:create, :destroy] do
      get :get_list
    end

    resources :like, only: [:create, :destroy] do
      get :get_list
    end

    resources :post, only: [:index, :show, :create, :update, :destroy] do
      get :get_list
    end

    resources :topic, only: [:index] do
      get :get_list
    end

    # Additional topic-related routes
    get "categories" => "mom_verse_category#index"
    get "topics" => "mom_verse_category#topics_list"
    get "latest", to: "topic#latest"
    get "popular", to: "topic#hot"
    get "top", to: "topic#top"
    get "tranding", to: "topic#tranding"
    get "latest_feed", to: "topic#latest_feed"
    get "show/:id", to: "topic#show"

    get "search", to: "mom_verse_category#search"
  end
end
