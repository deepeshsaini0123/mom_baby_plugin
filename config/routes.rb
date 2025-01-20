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
  get "/list_admin_user" => "admin_user#list_admin_user"
end
