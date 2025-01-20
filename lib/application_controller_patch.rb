module ApplicationControllerPatch
    def self.included(base)
      base.class_eval do
        # before_action :my_plugin_before_

        def handle_unverified_request
          # Example: Add a custom header or log a message
          Rails.logger.info "MyPlugin: Before action hook triggered."
        end
      end
    end
  end