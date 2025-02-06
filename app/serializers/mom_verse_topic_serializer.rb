class MomVerseTopicSerializer < ActiveModel::Serializer
  attributes :id, :title, :created_at, :updated_at
  has_many :posts, serializer: MomVersePostSerializer, embed: :objects
end
