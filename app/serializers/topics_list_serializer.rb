class TopicsListSerializer < ::ApplicationSerializer
  include TopicTagsMixin

  attributes :id,
             :views,
             :liked_by_user,
             :like_count,
             :reply_count,
             :posts_count,
             :has_summary,
             :archetype,
             :last_poster_username,
             :category_id,
             :category_name,
             :category_topics_counts,
             :op_like_count,
             :pinned_globally,
             :liked_post_numbers,
             :featured_link,
             :featured_link_root_domain,
             :allowed_user_count,
             :participant_groups,
             :content,
             :topic_id,
             :topic_title,
             :image_url,
             :created_at,
             :created_by_user,
             :created_by_id,
             :user_description,
             :member_counts,
             :uploaded_logo,
             :uploaded_logo_dark,
             :uploaded_background,
             :uploaded_background_dark

  def created_by_id
    object.user&.id
  end

  def created_by_user
    object.user&.name
  end

  def user_description
    object.user.custom_fields['user_description'] rescue nil
  end

  def member_counts
    object.category.custom_fields['member_counts'] || 0 rescue nil
  end

  def topic_id
    object.id
  end

  def topic_title
    object.title
  end

  def content
    object.excerpt
  end

  def category_name
    object.category&.name
  end

  def category_topics_counts
    object.category&.topic_count
  end

  def posts_count
    object.custom_fields["share_count"].present? ? object.custom_fields["share_count"] : 0
  end

  def uploaded_logo
    object.category&.uploaded_logo&.url
  end

  def uploaded_logo_dark
    object.category&.uploaded_logo_dark&.url
  end

  def uploaded_background
    object.category&.uploaded_background&.url
  end

  def uploaded_background_dark
    object.category&.uploaded_background_dark&.url
  end

  def liked_by_user
    scope.user&.username rescue nil
  end

  def include_participant_groups?
    object.private_message?
  end

  def posters
    object.posters || object.posters_summary || []
  end

  def op_like_count
    object.first_post && object.first_post.like_count
  end

  def last_poster_username
    posters.find { |poster| poster.user.id == object.last_post_user_id }.try(:user).try(:username)
  end

  def category_id
    # If it's a shared draft, show the destination topic instead
    if object.includes_destination_category && object.shared_draft
      return object.shared_draft.category_id
    end

    object.category_id
  end

  def participants
    object.participants_summary || []
  end

  def participant_groups
    object.participant_groups_summary || []
  end

  def include_liked_post_numbers?
    include_post_action? :like
  end

  def include_post_action?(action)
    object.user_data && object.user_data.post_action_data &&
      object.user_data.post_action_data.key?(PostActionType.types[action])
  end

  def liked_post_numbers
    object.user_data.post_action_data[PostActionType.types[:like]]
  end

  def include_participants?
    object.private_message?
  end

  def include_op_like_count?
    # PERF: long term we probably want a cheaper way of looking stuff up
    # this is rather odd code, but we need to have op_likes loaded somehow
    # simplest optimisation is adding a cache column on topic.
    object.association(:first_post).loaded?
  end

  def include_featured_link?
    SiteSetting.topic_featured_link_enabled
  end

  def include_featured_link_root_domain?
    SiteSetting.topic_featured_link_enabled && object.featured_link.present?
  end

  def allowed_user_count
    # Don't use count as it will result in a query
    object.allowed_users.length
  end

  def include_allowed_user_count?
    object.private_message?
  end
end
