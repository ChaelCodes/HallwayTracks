# frozen_string_literal: true

# Routes requests for Profiles
class ProfilesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_profile, only: %i[show edit update destroy]
  before_action :new_profile, only: :create

  # GET /profiles or /profiles.json
  def index
    @profiles = policy_scope(Profile)
  end

  # GET /profiles/1 or /profiles/1.json
  def show
    @events = @profile.events if policy(@profile).show_details?
    @your_friendship = Friendship.find_or_initialize_by buddy: current_profile, friend: @profile
    @your_friendship = nil unless @your_friendship.valid?
    @their_friendship = Friendship.find_or_initialize_by friend: current_profile, buddy: @profile
    @their_friendship = nil unless @their_friendship.valid? && policy(@their_friendship).show?
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
    authorize @profile
  end

  # GET /profiles/1/edit
  def edit; end

  # POST /profiles or /profiles.json
  def create
    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: "Profile was successfully created." }
        format.json { render :show, status: :created, location: @profile }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /profiles/1 or /profiles/1.json
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to @profile, notice: "Profile was successfully updated." }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1 or /profiles/1.json
  def destroy
    @profile.destroy
    respond_to do |format|
      format.html { redirect_to profiles_url, notice: "Profile was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def new_profile
    @profile = Profile.new(profile_params)
    @profile.user = current_user
    authorize @profile
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_profile
    @profile = Profile.find_by("LOWER(handle) = ?", params[:id]&.downcase)
    @profile ||= Profile.find(params[:id])
    authorize @profile
  end

  # Only allow a list of trusted parameters through.
  def profile_params
    params.require(:profile).permit(:bio, :handle, :name, :visibility)
  end
end
