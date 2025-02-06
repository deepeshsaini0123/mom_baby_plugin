class MomVersePostSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :content, :created_at, :updated_at
end
