class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @profile = current_user.profile
  end

  def update
    @profile = current_user.profile

    if @profile.update(profile_params)
      redirect_to user_path(current_user), notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy_photo
    @profile = current_user.profile
    @profile.photo.purge_later if @profile.photo.attached?
    redirect_to edit_profile_path, notice: "Photo removed."
  end

  private

  def profile_params
    params.require(:profile).permit(:display_name, :bio, :photo)
  end
end
