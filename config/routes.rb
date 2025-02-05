# frozen_string_literal: true

# MomAndBabyCommunityPlugin::Engine.routes.draw do
#   get "/examples" => "examples#index"
#   # define routes here
# end

# Discourse::Application.routes.draw { mount ::MomAndBabyCommunityPlugin::Engine, at: "mom-and-baby-community-plugin" }

Discourse::Application.routes.append do
  get "/examples" => "mom_and_baby_community_plugin/examples#index"
  get "/my_custom" => "my_custom#index"

  # Admin User Api's
  post "/create_admin_user" => "admin_user#create_admin_user"
  post "/create_new_user" => "admin_user#create_new_user"
  get "/list_admin_user" => "admin_user#list_admin_user"


  get "mom_verse/post" => "mom_verse_post#index" # post
  get "mom_verse/latest" => "mom_verse_post#latest" # latest_post
  get "mom_verse/popular" => "mom_verse_post#hot" # post for me
  get "mom_verse/top" => "mom_verse_post#top" # post for me
  get "mom_verse/tranding" => "mom_verse_post#hot" # tranding post


  get "mom_verse/latest_feed" => "mom_verse_post#latest_feed" # tranding post

  get "mom_verse/categories" => "mom_verse_category#index"
  get "mom_verse/topics" => "mom_verse_category#topics_list"
end
