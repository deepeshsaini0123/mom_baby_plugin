module ApplicationControllerPatch
  def self.included(base)
    base.class_eval do
      # before_action :handle_unverified_request
      before_action :check_and_set_current_user

      def handle_unverified_request
      end

      def check_and_set_current_user
        # Need to add logic
      end
    end
  end
end