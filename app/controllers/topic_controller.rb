class TopicController < ApplicationController
  include TopicListResponder
  include TopicListConcern
  attr_accessor :current_user

  def index
    list = get_discourse_response('latest')

    respond_to do |format|
      format.json { render_serialized(list, PostListSerializer) }
    end
  end

  def tranding
    all_topics = Category.where.not(parent_category_id: nil)

    all_topics = all_topics
      .includes(:topics)
      .order("post_count DESC")

    respond_to do |format|
      format.json { render_serialized(all_topics, MomVerseCategorySerializer) }
    end
  end

  def show
    topic = Topic.find_by(id: params[:id])
    raise Discourse::NotFound unless topic.present?
    respond_to do |format|
      format.json { render_serialized(topic, MomVerseTopicSerializer) }
    end
  end

  def latest
    @list = get_all_topics.order(created_at: :desc)

    render_topic_list
  end

  def top
    @list = get_all_topics.order(created_at: :desc)

    render_topic_list
  end

  def hot
    @list = get_all_topics.order(created_at: :desc)

    render_topic_list
  end

  def latest_feed
    discourse_expires_in 1.minute

    options = { order: "created" }.merge(build_topic_list_options)

    @title = "#{SiteSetting.title} - #{I18n.t("rss_description.latest")}"
    @link = "#{Discourse.base_url}/latest"
    @atom_link = "#{Discourse.base_url}/latest.rss"
    @description = I18n.t("rss_description.latest")
    @topic_list = TopicQuery.new(nil, options).list_latest

    render "list", formats: [:rss]
  end

  def top_feed
    discourse_expires_in 1.minute

    @title = "#{SiteSetting.title} - #{I18n.t("rss_description.top")}"
    @link = "#{Discourse.base_url}/top"
    @atom_link = "#{Discourse.base_url}/top.rss"
    @description = I18n.t("rss_description.top")
    period = params[:period] || SiteSetting.top_page_default_timeframe.to_sym
    TopTopic.validate_period(period)

    @topic_list = TopicQuery.new(nil).list_top_for(period)

    render "list", formats: [:rss]
  end

  def hot_feed
    discourse_expires_in 1.minute

    @topic_list = TopicQuery.new(nil).list_hot

    render "list", formats: [:rss]
  end

  private

  def render_topic_list
    render json: {topics: serialize_data(@list, TopicsListSerializer)}
  end
end
