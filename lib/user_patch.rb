module UserPatch
  def self.included(base)
    base.class_eval do

      # User model changes should be here
      # def username        

      # end
    end
  end
end