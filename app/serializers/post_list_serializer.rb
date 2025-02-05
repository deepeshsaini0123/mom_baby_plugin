class PostListSerializer < ::ApplicationSerializer
  attributes :can_create_topic,
             :more_topics_url,
             :for_period,
             :per_page,
             :page,
             :top_tags,
             :tags,
             :current_user_values,
             :shared_drafts

  has_many :topics, serializer: TopicsListSerializer, embed: :objects

  def initialize(object, options = {})
    super
    options[:filter] = object.filter
  end

  def can_create_topic
    scope.can_create?(Topic)
  end

  def current_user_values
    scope.current_user.id rescue nil
  end

  def include_shared_drafts?
    object.shared_drafts.present?
  end

  def include_for_period?
    for_period.present?
  end

  def include_more_topics_url?
    object.more_topics_url.present? && (object.topics.size == object.per_page)
  end

  def include_top_tags?
    Tag.include_tags?
  end

  def include_tags?
    SiteSetting.tagging_enabled && object.tags.present?
  end

  def include_categories?
    scope.can_lazy_load_categories?
  end

  def page
    str = object.more_topics_url.split('?').last rescue nil
    eval("{"+str.gsub('=',':').gsub('&',',')+"}")[:page].to_i - 1 rescue nil
  end

end
