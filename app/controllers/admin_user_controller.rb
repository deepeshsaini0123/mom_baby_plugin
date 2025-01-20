class AdminUserController < ::ApplicationController


  def create_admin_user
    user = User.new(user_params)
    user.active = true
    user.admin = true
    user.approved = true
    user.approved_at = Time.now
    user.approved_by_id = -1
    user.flag_level = 0
    user.moderator = true
    user.username_lower = params[:username].underscore
    user.email = params[:email]
    user.trust_level = 4

    if user.save
      user.email_tokens.create(email: user.email, confirmed: true) rescue nil
      render json: { message: "User created successfully!!!" }
    else
      render json: { message: "Something went wrong #{user.errors.full_messages}." }
    end
  end

  def list_admin_user
    users = User.where(admin: true)
    user_hash = users.map do |user|
      {
        user_name: user.username,
        email: user.email,
        name: user.name,
        date_of_birth: user.date_of_birth,
        admin: user.admin
      }
    end
    render json: {users: user_hash}
  end

  private

  def user_params
    params.permit(:date_of_birth, :name, :username, :password)
  end
end
