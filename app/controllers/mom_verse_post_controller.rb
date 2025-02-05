class MomVersePostController < ::ApplicationController
  include TopicListResponder
  attr_accessor :current_user

  def index
    list_opts = build_topic_list_options
    user = list_target_user
    list = TopicQuery.new(user, list_opts).public_send("list_latest")

    respond_to do |format|
      format.json { render_serialized(list, PostListSerializer) }
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

  def topics_list
    categories = Category.where(parent_category_id: params[:category_id])
    categories ||= Category.where.not(parent_category_id: nil)
    categories = (ActiveModel::ArraySerializer.new(categories, each_serializer: MomVerseCategorySerializer).as_json)
    render json: {categories: categories}
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

  protected

  def next_page_params
    page_params.merge(page: params[:page].to_i + 1)
  end

  def prev_page_params
    pg = params[:page].to_i
    if pg > 1
      page_params.merge(page: pg - 1)
    else
      page_params.merge(page: nil)
    end
  end

  private

  def get_discourse_response(filter = 'latest')
    list_opts = build_topic_list_options
    user = list_target_user
    list = TopicQuery.new(user, list_opts).public_send("list_latest")
    if guardian.can_create_shared_draft? && @category.present?
      if @category.id == SiteSetting.shared_drafts_category.to_i
        list.topics.each { |t| t.includes_destination_category = t.shared_draft.present? }
      else
        shared_drafts =
          TopicQuery.new(
            user,
            category: SiteSetting.shared_drafts_category,
            destination_category_id: list_opts[:category],
          ).list_latest

        if shared_drafts.present? && shared_drafts.topics.present?
          list.shared_drafts = shared_drafts.topics
        end
      end
    end

    list.more_topics_url = construct_url_with(:next, list_opts)
    list.prev_topics_url = construct_url_with(:prev, list_opts)

    if Discourse.anonymous_filters.include?(filter)
      @description = SiteSetting.site_description
      @rss = filter
      @rss_description = filter

      # Note the first is the default and we don't add a title
      if (filter.to_s != current_homepage) && use_crawler_layout?
        filter_title = I18n.t("js.filters.#{filter}.title", count: 0)

        if list_opts[:category] && @category
          @title =
            I18n.t("js.filters.with_category", filter: filter_title, category: @category.name)
        else
          @title = I18n.t("js.filters.with_topics", filter: filter_title)
        end

        @title << " - #{SiteSetting.title}"
      elsif @category.blank? && (filter.to_s == current_homepage) &&
            SiteSetting.short_site_description.present?
        @title = "#{SiteSetting.title} - #{SiteSetting.short_site_description}"
      end
    end

    # render json: { topic: render_serialized(list, PostListSerializer) }
    respond_to do |format|
      format.json { render_serialized(list, PostListSerializer) }
    end
  end

  def page_params
    route_params = { format: "json" }

    if @category.present?
      slug_path = @category.slug_path

      route_params[:category_slug_path_with_id] = (slug_path + [@category.id.to_s]).join("/")
    end

    route_params[:username] = UrlHelper.encode_component(params[:username]) if params[
      :username
    ].present?
    route_params[:period] = params[:period] if params[:period].present?
    route_params
  end

  def list_target_user
    if params[:user_id] && guardian.is_staff?
      User.find(params[:user_id].to_i)
    else
      current_user
    end
  end

  def build_topic_list_options
    options = {}
    params[:tags] = [params[:tag_id], *Array(params[:tags])].uniq if params[:tag_id].present?

    TopicQuery.public_valid_options.each do |key|
      if params.key?(key) && (val = params[key]).present?
        options[key] = val
        raise Discourse::InvalidParameters.new key if !TopicQuery.validate?(key, val)
      end
    end

    # hacky columns get special handling
    options[:topic_ids] = param_to_integer_list(:topic_ids)

    options
  end

  def user_params
    params.permit(:date_of_birth, :name, :username, :password)
  end

  def construct_url_with(action, opts, url_prefix = nil)
    method = url_prefix.blank? ? "#{action_name}_path" : "#{url_prefix}_#{action_name}_path"

    page_params =
      case action
      when :prev
        prev_page_params
      when :next
        next_page_params
      else
        raise "unreachable"
      end

    opts = opts.dup
    if SiteSetting.unicode_usernames && opts[:group_name]
      opts[:group_name] = UrlHelper.encode_component(opts[:group_name])
    end
    opts.delete(:category) if page_params.include?(:category_slug_path_with_id)
    url = public_send(method, opts.merge(page_params)).sub(".json?", "?")
    url = UrlHelper.unencode(url) if SiteSetting.unicode_usernames
    url
  end
end
