module DefaultCurrentUserProviderPatch
  def self.included(base)
    base.class_eval do
      alias_method :current_user_without_override, :current_user

      # Authenticated model changes should be here
      def current_user
        if false # Need some condition based on that we set current user by our or original method.
          # Will add our own authentication method here
          # User.find(8)
        else
          current_user_without_override
        end
      end
    end
  end
end