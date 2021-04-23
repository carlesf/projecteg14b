class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show edit update destroy point unvote]
  
# :view => 'newReply'
  def point
    @comment.points += 1
    @comment.save
          
    Vote.create(votable_id: @comment.id, votable_type: 'comment', voter_id: current_user.id)
    
    respond_to do |format|
      @view = params[:view]
      if @view == 'newReply'
        #MAL
        #if params[:r]
         # format.html { redirect_to '/replies/new?commentreply_id='+@comment.id.to_s+'&r=1&contr='+params[:contr].to_s }

          
        #else
          # FUNCIONA !!!
         # format.html { redirect_to '/replies/new?commentreply_id='+@comment.id.to_s }
          
        #end
        
        # pare = comment
        format.html { redirect_to '/replies/new?commentreply_id='+@comment.id.to_s }

        
      else @view == 'show'
        # FUNCIONA !!!
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
        #MAL
=begin        if params[:r]
          format.html { redirect_to '/replies/new?commentreply_id='+@comment.id.to_s+'&r=1&contr='+params[:contr].to_s }

          
        else
          # FUNCIONA !!!
          format.html { redirect_to '/replies/new?commentreply_id='+@comment.id.to_s }
          
        end
=end        
        format.html { redirect_to '/replies/new?commentreply_id='+@comment.id.to_s}
      else @view == 'show'
        # FUNCIONA !!!
        format.html { redirect_to Contribution.find_by(id: Contribution.find_by(id: @comment.contr_id)) }
      end
    end 
          
    @vote = Vote.find_by(votable_id: @comment.id, votable_type: 'comment', voter_id: current_user.id)
    @vote.destroy
  end

  # GET /comments or /comments.json
  def index
    
    if params[:user_id]
      @comments = Comment.where(user_id: params[:user_id]).order(created_at: :desc)
    elsif params[:threads]
      @comments = Comment.all
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
