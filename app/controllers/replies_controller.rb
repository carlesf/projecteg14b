class RepliesController < ApplicationController
  before_action :set_reply, only: %i[ show edit update destroy ]

  # GET /replies or /replies.json
  def index
   #@comment = Comment.find_by(id: params[:commentreply_id])
    @replies = Reply.all
  end

  # GET /replies/1 or /replies/1.json
  def show
  end

  # GET /replies/new
  def new
    @reply = Reply.new
  end

  # GET /replies/1/edit
  def edit
  end

  # POST /replies or /replies.json
  def create
    @reply = Reply.new(reply_params)
    @reply.user_id = current_user.id
    @reply.commentreply_id = params[:commentreply_id]

    respond_to do |format|
      if @reply.save
        if params[:r]
          format.html { redirect_to '/contributions/'+params[:contr], notice: "Reply was successfully created." }
          format.json { render :show, status: :created, location: @reply }
        else
          format.html { redirect_to Contribution.find_by(id: Comment.find_by(id: @reply.commentreply_id).contr_id), notice: "Reply was successfully created." }
          format.json { render :show, status: :created, location: @reply }
        end

      else
        if @reply.content.blank?
          if params[:r]
            format.html { redirect_to '/replies/new?commentreply_id='+params[:commentreply_id]+'&r=1&contr='+params[:contr], alert: "Reply cannot be empty." }
          else
            format.html { redirect_to '/replies/new?commentreply_id='+params[:commentreply_id], alert: "Reply cannot be empty." }
          end
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @reply.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /replies/1 or /replies/1.json
  def update
    respond_to do |format|
      if @reply.update(reply_params)
        format.html { redirect_to @reply, notice: "Reply was successfully updated." }
        format.json { render :show, status: :ok, location: @reply }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reply.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /replies/1 or /replies/1.json
  def destroy
    for r in Reply.where(commentreply_id: @reply.id)
      r.destroy
    end
    
    @reply.destroy
    respond_to do |format|
      format.html { redirect_to replies_url, notice: "Reply was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reply
      @reply = Reply.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def reply_params
      params.require(:reply).permit(:content, :user_id, :commentreply_id, :r, :contr)
    end
end
