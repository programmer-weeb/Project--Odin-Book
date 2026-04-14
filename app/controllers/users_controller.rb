class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :friends]

  def index
    @users = User.includes(:profile).order(:email)
  end

  def show
  end

  def friends
  end

end
