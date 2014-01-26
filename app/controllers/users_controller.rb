class UsersController < ApplicationController
	before_action :signed_in_user,	only: [:index, :edit, :update, :following, :followers]
	before_action :existing_user,		only: [:new, :create]
	before_action :correct_user,		only: [:edit, :update]
	before_action :admin_user,			only: [:destroy]

	def index
		@users = User.paginate(page: params[:page])
	end

  def new
		@user = User.new
  end

	def create
		@user = User.new(user_params)
		if @user.save
			sign_in @user
			flash[:success] = "Welcome to the Sample App!"
			redirect_to @user
		else
			render 'new'
		end
	end

	def show
		@user = User.find(params[:id])
		@microposts = @user.microposts.paginate(page: params[:page])
	end

	def edit
	end

	def update
		if @user.update_attributes(user_params)
			flash[:success] = "Profile updated"
			redirect_to @user
		else
			render 'edit'
		end
	end

	def destroy
		user = User.find(params[:id])
		if current_user == user
			flash[:error] = "You cannot delete your own account"
			render 'index'
		else
			user.destroy
			flash[:success] = "User deleted."
			redirect_to users_url
		end
	end

	def following
		@title = "Following"
		@user = User.find(params[:id])
		@users = @user.followed_users.paginate(page: params[:page])
		render 'show_follow'
	end

	def followers
		@title = "Followers"
		@user = User.find(params[:id])
		@users = @user.followers.paginate(page: params[:page])
		render 'show_follow'
	end

	private

	def user_params
		params.require(:user).permit(:name,
																 :email,
																 :password,
																 :password_confirmation,
																)
	end

	# Before filters

	def existing_user
		if signed_in?
			redirect_to(root_url) if signed_in?
		end
	end

	def correct_user
		@user = User.find(params[:id])
		redirect_to(root_url) unless current_user?(@user)
	end

	def admin_user
		redirect_to(root_url) unless current_user.admin?
	end
end
