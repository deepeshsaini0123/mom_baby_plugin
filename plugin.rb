# frozen_string_literal: true

# name: mom-and-baby-community-plugin
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Humanx
# url: TODO
# required_version: 2.7.0

enabled_site_setting :mom_and_baby_community_plugin_enabled

module ::MomAndBabyCommunityPlugin
  PLUGIN_NAME = "mom-and-baby-community-plugin"
end

require_relative "lib/mom_and_baby_community_plugin/engine"

after_initialize do
  load File.expand_path('config/routes.rb', __dir__)

  # Apply the patch to ApplicationController
  require_dependency File.expand_path("../lib/application_controller_patch.rb", __FILE__)
  ::ApplicationController.class_eval do
    include ::ApplicationControllerPatch
  end

  # Apply the patch to User
  require_dependency File.expand_path("../lib/user_patch.rb", __FILE__)
  ::ApplicationController.class_eval do
    include ::UserPatch
  end

end
