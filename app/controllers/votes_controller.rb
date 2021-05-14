class VotesController < ApplicationController
  before_action :set_vote, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token
  
  # GET /votes
  # GET /votes.json
  def index
    @votes = Vote.all
  end

  # GET /votes/1
  # GET /votes/1.json
  def show
  end

  # GET /votes/new
  def new
    @vote = Vote.new
  end

  # GET /votes/1/edit
  def edit
  end

  # POST /votes
  # POST /votes.json
  def create
    respond_to do |format|
      if request.headers['X-API-KEY'] || !current_user.nil?
        @apikey = request.headers['X-API-KEY']
        if !@apikey.nil? && User.where(uid: @apikey).empty?
          format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Incorrect authentication"}, :status => 401 }
        else
          @user = User.find_by(uid: @apikey)
          if !@apikey.nil? && (params[:votable_type].to_s != "contribution" && params[:votable_type].to_s != "comment" && params[:votable_type].to_s != "reply")
            format.json { render :json => {:status => 400, :error => "Bad Request", :message => "Votable_type must be contribution, comment or reply"}, :status => 400 }
          elsif !@apikey.nil? && params[:votable_type].empty?
            format.json { render :json => {:status => 400, :error => "Bad Request", :message => "Votable_type cannot be empty"}, :status => 400 }
          elsif !@apikey.nil? && params[:votable_id].nil?
            format.json { render :json => {:status => 400, :error => "Bad Request", :message => "Votable_id cannot be empty"}, :status => 400 }
          elsif !@apikey.nil? && (Contribution.where(id: params[:votable_id]).empty? && Comment.where(id: params[:votable_id]).empty? && Reply.where(id: params[:votable_id]).empty?)
            format.json { render :json => {:status => 404, :error => "Not Found", :message => "No Contribution, Comment or Reply with that votable_id"}, :status => 404 }
          elsif !@apikey.nil? && !Vote.where(votable_id: params[:votable_id], votable_type: params[:votable_type], voter_id: @user.id).empty?
            format.json { render :json => {:status => 409, :error => "Conflict", :message => "Trying to vote a Contribution, Comment or Reply twice"}, :status => 409 }
          else
            @vote
            if !current_user.nil?
              @vote = Vote.new(vote_params)
            else
              @vote = Vote.new
              @vote.votable_id = params[:votable_id]
              @vote.votable_type = params[:votable_type]
              @vote.voter_id = @user.id
            end
          
            if @vote.save
              if !@apikey.nil?
                if params[:votable_type].to_s == "contribution"
                  @contribution = Contribution.find(params[:votable_id])
                  @contribution.points += 1
                  @contribution.save
                elsif params[:votable_type].to_s == "comment"
                  @comment = Comment.find(params[:votable_id])
                  @comment.points += 1
                  @comment.save
                end
              end
              format.html { redirect_to @vote, notice: 'Vote was successfully created.' }
              format.json { render json: @vote.to_json(only: [:id, :votable_id, :votable_type, :voter_id, :created_at]), :status => 201 }
            else
              format.html { render :new }
              format.json { render json: @vote.errors, status: :unprocessable_entity }
            end
          
          end
          
        end
        
      else
        format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Missing authentication"}, :status => 401 }
      end
      
    end
  end
  

  # PATCH/PUT /votes/1
  # PATCH/PUT /votes/1.json
  def update
    respond_to do |format|
      if @vote.update(vote_params)
        format.html { redirect_to @vote, notice: 'Vote was successfully updated.' }
        format.json { render :show, status: :ok, location: @vote }
      else
        format.html { render :edit }
        format.json { render json: @vote.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /votes/1
  # DELETE /votes/1.json
  def destroy
    respond_to do |format|
      if request.headers['X-API-KEY'] || !current_user.nil?
        @apikey = request.headers['X-API-KEY']
        if !@apikey.nil? && User.where(uid: @apikey).empty?
          format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Incorrect authentication"}, :status => 401 }
        else
          @user = User.find_by(uid: @apikey)
          if !@apikey.nil? && Vote.where(id: params[:id]).empty?
            format.json { render :json => {:status => 404, :error => "Not Found", :message => "No Vote with that vote_id"}, :status => 404 }
          elsif !@apikey.nil? && !(Vote.find(params[:id]).voter_id.to_s == @user.id.to_s)
            format.json { render :json => {:status => 403, :error => "Forbidden", :message => "Privilege not granted"}, :status => 403 }
          else
            if !@apikey.nil?
              if @vote.votable_type.to_s == "contribution"
                @contribution = Contribution.find(@vote.votable_id)
                @contribution.points -= 1
                @contribution.save
              elsif @vote.votable_type.to_s == "comment"
                @comment = Comment.find(@vote.votable_id)
                @comment.points -= 1
                @comment.save
              end
            end
            @vote.destroy
            format.html { redirect_to votes_url, notice: 'Vote was successfully destroyed.' }
            format.json { head :no_content, :status => 204 }
          
          end
          
        end
        
      else
        format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Missing authentication"}, :status => 401 }
      end
      
    end
    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vote
      if !Vote.where(id: params[:id]).empty?
        @vote = Vote.find(params[:id])
      end
    end

    # Only allow a list of trusted parameters through.
    def vote_params
      params.require(:vote).permit(:votable_id, :votable_type, :voter_id)
    end
end
