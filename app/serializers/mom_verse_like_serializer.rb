class MomVerseLikeSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :post_id, :created_at
end