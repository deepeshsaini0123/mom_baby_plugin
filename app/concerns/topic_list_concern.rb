module TopicListConcern
  extend ActiveSupport::Concern

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

  def get_all_topics
    Topic.includes(:posts).all
  end

  def get_discourse_response(filter = 'latest')
    list_opts = build_topic_list_options
    user = list_target_user
    list = TopicQuery.new(user, list_opts).public_send("list_#{filter}")
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
    list
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
