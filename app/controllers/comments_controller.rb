class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show edit update destroy point unvote]
  
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
            @comments = Comment.where(user_id: params[:user_id])
            format.html { @comments }
            format.json { render json: @comments.to_json(only: [:id, :content, :user_id, :contr_id, :created_at, :points]) }
          end
  
  
      elsif params[:upvotedC]
        
        if request.headers['X-API-KEY']
          @apikey = request.headers['X-API-KEY']
          if !User.where(uid: @apikey).empty?
            @user = User.find_by(uid: @apikey)
            if params[:upvotedC]
              @votes = Vote.where(voter_id: @user.id, votable_type: 'comment').select(:votable_id)
              @comments = Comment.where(id: @votes)
              format.json { render json: @comments.to_json(only: [:id, :content, :user_id, :contr_id, :created_at, :points]) }
            else
              format.json { render :json => {:status => 403, :error => "Forbidden", :message => "Privilege not granted"}, :status => 403 }
            end
          else
            format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Incorrect authentication"}, :status => 401 }
          end
        else
          format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Missing authentication"}, :status => 401 }
          if !current_user.nil?
            @votes = Vote.where(voter_id: current_user.id, votable_type: 'comment').select(:votable_id)
            @comments = Comment.where(id: @votes)
            format.html { @comments }
          end
        end
        
      elsif params[:threads]
        # no se com mirar si esta logged / quin es el logged
        @comments = Comment.where(user_id: current_user.id)
        format.html { @comments }
        format.json { render json: @comments.to_json(only: [:id, :content, :user_id, :contr_id, :created_at, :points]) }
        
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
    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id
    @comment.contr_id = params[:contr_id]

    respond_to do |format|
      if @comment.save
        format.html { redirect_to Contribution.find_by(id:  params[:contr_id]) , notice: "Comment was successfully created." }
        format.json { render :show, status: :created, location: @comment }
      else
        if @comment.content.blank?
          format.html { redirect_to Contribution.find_by(id: params[:contr_id]), alert: "Comment cannot be empty." }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @comment.errors, status: :unprocessable_entity }
        end
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
