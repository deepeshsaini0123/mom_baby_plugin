class TopicController < ApplicationController
  include TopicListResponder
  include TopicListConcern
  attr_accessor :current_user

  def index
    list_opts = build_topic_list_options
    user = list_target_user
    list = TopicQuery.new(user, list_opts).public_send("list_latest")

    respond_to do |format|
      format.json { render_serialized(list, PostListSerializer) }
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
    get_discourse_response('latest')
  end

  def top
    get_discourse_response('top')
  end

  def hot
    get_discourse_response('hot')
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
end
