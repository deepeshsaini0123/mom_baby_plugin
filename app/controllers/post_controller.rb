class PostController < ::ApplicationController

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

  def create
  end

  def show
    by_id_finder = Post.where(id: params[:id] || params[:post_id])
    post = find_post_using(by_id_finder)
    render_post_json(post)
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

  private

  def find_post_using(finder)
    post = finder.with_deleted.first
    raise Discourse::NotFound unless post.present?
    raise Discourse::NotFound unless post.topic ||= Topic.with_deleted.find_by(id: post.topic_id)
    post
  end
end
