class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show edit update destroy point unvote]
  skip_before_action :verify_authenticity_token
  
  def point
    @comment.points += 1
    @comment.save
          
    Vote.create(votable_id: @comment.id, votable_type: 'comment', voter_id: current_user.id)
    
    respond_to do |format|
      @view = params[:view]
      if @view == 'newReply'
        format.html { redirect_to '/replies/new?commentreply_id='+@comment.id.to_s }
      else @view == 'show'
        format.html { redirect_to Contribution.find_by(id: Contribution.find_by(id: @comment.contr_id)) }
      end
    end 
  end



  def unvote
    @comment.points -= 1
    @comment.save
    
    respond_to do |format|
      @view = params[:view]
      if @view == 'newReply'
        format.html { redirect_to '/replies/new?commentreply_id='+@comment.id.to_s}
      else @view == 'show'
        format.html { redirect_to Contribution.find_by(id: Contribution.find_by(id: @comment.contr_id)) }
      end
    end 
          
    @vote = Vote.find_by(votable_id: @comment.id, votable_type: 'comment', voter_id: current_user.id)
    @vote.destroy
  end

  # GET /comments or /comments.json
  def index
    respond_to do |format|
      if params[:user_id]
        @user = User.where(id: params[:user_id])
        if @user.empty?
          format.json { render :json => {:status => 404, :error => "Not Found", :message => "No User with that user_id"}, :status => 404 }
        else
          @comments = Comment.where(user_id: params[:user_id]).order(created_at: :desc)
          format.html { @comments }
          format.json { render json: @comments.to_json(only: [:id, :content, :user_id, :contr_id, :created_at]) }
        end
      elsif params[:upvotedC]
        if !User.where(id: params[:upvotedC]).empty?
          if request.headers['X-API-KEY']
            @apikey = request.headers['X-API-KEY']
            if !User.where(uid: @apikey).empty?
              @user = User.find_by(uid: @apikey)
              # aquest if? si upvotedC nomes li posem 1, sempre seran del logged in User
              if params[:upvotedC].to_s == @user.id.to_s
                @votes = Vote.where(voter_id: @user.id, votable_type: 'comment').select(:votable_id)
                @comments = Comment.where(id: @votes)
                format.json { render json: @comments.to_json(only: [:id, :content, :user_id, :contr_id, :created_at]) }
              else
                format.json { render :json => {:status => 403, :error => "Forbidden", :message => "Privilege not granted"}, :status => 403 }
              end
            else
              format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Incorrect authentication"}, :status => 401 }
            end
          else
            format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Missing authentication"}, :status => 401 }
            ## Cas extrem per l'API REST en que el user_id = 1 coincideix amb upvotedC = 1
            if !current_user.nil?
              @votes = Vote.where(voter_id: current_user.id, votable_type: 'comment').select(:votable_id)
              @comments = Comment.where(id: @votes)
              format.html { @comments }
            end
          end
          
        else
          if !current_user.nil?
            @votes = Vote.where(voter_id: current_user.id, votable_type: 'comment').select(:votable_id)
            @comments = Comment.where(id: @votes)
            format.html { @comments }
          end
          format.json { render :json => {:status => 404, :error => "Not Found", :message => "No user with that user_id"}, :status => 404 }
        end
        
      elsif params[:threads]
        @comments = Comment.where(user_id: current_user.id)
        format.html { @comments }
      end
    end
    
  end

  # GET /comments/1 or /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments or /comments.json
  def create
    respond_to do |format|
      if request.headers['X-API-KEY'] || !current_user.nil?
        @apikey = request.headers['X-API-KEY']
        if !@apikey.nil? && User.where(uid: @apikey).empty?
          format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Incorrect authentication"}, :status => 401 }
        else
          if Contribution.where(id: params[:contr_id]).empty?
            format.json { render :json => {:status => 404, :error => "Not Found", :message => "No Contribution with that contribution_id"}, :status => 404 }
          else
            @comment
            if !current_user.nil?
              @comment = Comment.new(comment_params)
              @comment.user_id = current_user.id
              @comment.contr_id = params[:contr_id]
            else
              @user = User.find_by(uid: @apikey)
              @comment = Comment.new
              @comment.content = params[:content]
              @comment.contr_id = params[:contr_id]
              @comment.user_id = @user.id
            end
            
            if @comment.save
              format.html { redirect_to Contribution.find_by(id:  params[:contr_id]) , notice: "Comment was successfully created." }
              format.json { render json: @comment.to_json(only: [:id, :content, :user_id, :contr_id, :created_at]), :status => 201 }
            else
              if @comment.content.blank?
                format.html { redirect_to Contribution.find_by(id: params[:contr_id]), alert: "Comment cannot be empty." }
                format.json { render :json => {:status => 400, :error => "Bad Request", :message => "Content cannot be empty"}, :status => 400 }
              elsif @comment.contr_id.blank?
                format.json { render :json => {:status => 400, :error => "Bad Request", :message => "Contr_id cannot be empty"}, :status => 400 }
              else # No existeix la contribució contr_id
                format.html { render :new, status: :unprocessable_entity }
                format.json { render json: @comment.errors, status: :unprocessable_entity }
              end
            end
          end
        end
        
      else
        format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Missing authentication"}, :status => 401 }
      end
      
    end
  end

  # PATCH/PUT /comments/1 or /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: "Comment was successfully updated." }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    
    for reply in Reply.where(commentreply_id: @comment.id)
      reply.destroy
    end
    
    @comment.destroy
        
    respond_to do |format|
      format.html { redirect_to comments_url, notice: "Comment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:content, :user_id, :contr_id, :contr)
    end
end
