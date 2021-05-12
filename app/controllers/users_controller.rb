class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]


  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show
    respond_to do |format|
      format.html { @user }
      if !User.where(id: params[:id]).empty?
          @user = User.find(params[:id])
          if request.headers['X-API-KEY']
            @apikey = request.headers['X-API-KEY'] 
            if @user == User.find_by(uid: @apikey)
            format.json { render json: @user.to_json(only: [:id, :about, :email, :created_at, :uid]) }  
            else
            format.json { render json: @user.to_json(only: [:id, :about, :email, :created_at, :uid => ""]) }
            end
          else
            format.json { render json: @user.to_json(only: [:id, :about, :email, :created_at, :uid => ""])}
          end
      else
        format.json { render :json => {:status => 404, :error => "Not Found", :message => "No user with that user_id"}, :status => 404 }
      end
    end
  end

  

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      if !User.where(id: params[:id]).empty?
        @user = User.find(params[:id])
      end
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:about, :email)
    end
end
