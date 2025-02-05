module ApplicationControllerPatch
  def self.included(base)
    base.class_eval do
      # before_action :handle_unverified_request
      before_action :check_and_set_current_user

      def handle_unverified_request

        # Example: Add a custom header or log a message
        Rails.logger.info "MyPlugin: Before action hook triggered."
      end

      def check_and_set_current_user
      end
    end
  end
end