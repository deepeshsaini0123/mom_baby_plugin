class MomVerseCategorySerializer < ::ApplicationSerializer
  attributes :id,
             :name,
             :color,
             :topic_id,
             :topic_count,
             :user_id,
             :topics_year,
             :topics_month,
             :topics_week,
             :slug,
             :description,
             :text_color,
             :read_restricted,
             :post_count,
             :latest_post_id,
             :latest_topic_id,
             :position,
             :parent_category_id,
             :posts_year,
             :posts_month,
             :posts_week,
             :topics_day,
             :posts_day,
             :name_lower,
             :uploaded_logo_url,
             :uploaded_background_dark,
             :members_count

  def members_count
    # need to add member follow logic
  end

  def uploaded_background_dark
    object.uploaded_background_dark&.url
  end

  def uploaded_logo_url
    object.uploaded_logo&.url
  end
end
