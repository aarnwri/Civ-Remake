class Api::V1::UsersController < Api::V1::ApplicationController

  skip_before_action :authenticate_user_by_token, only: [:create]

  def create
    return unless clean_http_basic_params

    if User.find_by(email: new_user_params[:email])
      render json: { errors: ["user already exists"] }.to_json, status: :forbidden
    else
      @user = User.new(email: new_user_params[:email], password: new_user_params[:password])
      if @user.save
        # @session = Session.create(user: @user)
        # @session.create_token
        @session = @user.session

        # included data
        @sessions = [@session]

        render :show, status: :created
      else
        render json: { errors: @user.errors.full_messages }.to_json, status: :unprocessable_entity
      end
    end
  end

  private

    def new_user_params
      params.require(:user).permit(:email, :password)
    end
end
