# frozen_string_literal: true
Discourse::Application.routes.append do
  # Admin User Api's
  post "/create_admin_user" => "admin_user#create_admin_user"
  post "/create_new_user" => "admin_user#create_new_user"
  get "/list_admin_user" => "admin_user#list_admin_user"

  get "mom_verse/post" => "post#index" # post
  get "mom_verse/latest" => "post#latest" # latest_post
  get "mom_verse/popular" => "post#hot" # post for me
  get "mom_verse/top" => "post#top" # post for me
  get "mom_verse/tranding" => "post#hot" # tranding post

  get "mom_verse/latest_feed" => "post#latest_feed" # tranding post

  get "mom_verse/categories" => "mom_verse_category#index"
  get "mom_verse/topics" => "mom_verse_category#topics_list"

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

    resources :topic, only: [:index, :show, :create, :update, :destroy] do
      get :get_list
    end
  end
end
