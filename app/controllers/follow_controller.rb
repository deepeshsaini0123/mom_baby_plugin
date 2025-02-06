class FollowController < ::ApplicationController

  def create
    render json: {message: 'Hello World'}
  end

  def destroy
  end
end
