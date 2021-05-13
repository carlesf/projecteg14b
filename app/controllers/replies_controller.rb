class RepliesController < ApplicationController
  before_action :set_reply, only: %i[ show edit update destroy point unvote]
  skip_before_action :verify_authenticity_token
  
  def point
    Vote.create(votable_id: @reply.id, votable_type: 'reply', voter_id: current_user.id)
    
    respond_to do |format|
      @view = params[:view]
      if @view == 'newReply'
        format.html { redirect_to '/replies/new?commentreply_id='+@reply.id.to_s+'&r=1&contr='+params[:contr].to_s }
      else @view == 'show'
        format.html { redirect_to Contribution.find_by(id: Contribution.find_by(id: Comment.find_by(id: @reply.commentreply_id).contr_id).id) }      
      end
    end 

  end


  def unvote
    @vote = Vote.find_by(votable_id: @reply.id, votable_type: 'reply', voter_id: current_user.id)
    @vote.destroy
    
    respond_to do |format|
      @view = params[:view]
      if @view == 'newReply'
        # AQUEST
        format.html { redirect_to '/replies/new?commentreply_id='+@reply.id.to_s+'&r=1&contr='+(Contribution.find_by(id: Contribution.find_by(id: Comment.find_by(id: @reply.commentreply_id).contr_id)).id).to_s }
      else @view == 'show'
        format.html { redirect_to Contribution.find_by(id: Contribution.find_by(id: Comment.find_by(id: @reply.commentreply_id).contr_id).id) }      
      end
    end 

          

  end

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
    respond_to do |format|
      if request.headers['X-API-KEY'] || !current_user.nil?
        @apikey = request.headers['X-API-KEY']
        if !@apikey.nil? && User.where(uid: @apikey).empty?
          format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Incorrect authentication"}, :status => 401 }
        else
          if params[:r] && Reply.where(id: params[:commentreply_id]).empty? # parent -> reply
            format.json { render :json => {:status => 404, :error => "Not Found", :message => "No Reply with that commentreply_id"}, :status => 404 }
          elsif !params[:r] && Comment.where(id: params[:commentreply_id]).empty? # parent -> comment
            format.json { render :json => {:status => 404, :error => "Not Found", :message => "No Comment with that commentreply_id"}, :status => 404 }
          else
            @reply
              if !current_user.nil?
                @reply = Reply.new(reply_params)
                @reply.user_id = current_user.id
              else
                @user = User.find_by(uid: @apikey)
                @reply = Reply.new
                @reply.user_id = @user.id
                @reply.content = params[:content]
                @reply.commentreply_id = params[:commentreply_id]
                
              end
              
              if params[:r]
                @reply.parent_type = true
              else
                @reply.parent_type = false
              end
              
            
              if @reply.save
                if params[:r]
                  format.html { redirect_to '/contributions/'+params[:contr], notice: "Reply was successfully created." }
                  format.json { render json: @reply.to_json(only: [:id, :content, :user_id, :commentreply_id, :parent_type, :created_at]), :status => 201 }
                else
                  format.html { redirect_to Contribution.find_by(id: Comment.find_by(id: @reply.commentreply_id).contr_id), notice: "Reply was successfully created." }
                  format.json { render json: @reply.to_json(only: [:id, :content, :user_id, :commentreply_id, :parent_type, :created_at]), :status => 201 }
                end
        
              else
                if @reply.content.blank?
                  if params[:r]
                    format.html { redirect_to '/replies/new?commentreply_id='+params[:commentreply_id]+'&r=1&contr='+params[:contr], alert: "Reply cannot be empty." }
                    format.json { render :json => {:status => 400, :error => "Bad Request", :message => "Content cannot be empty"}, :status => 400 }
                  else
                    format.html { redirect_to '/replies/new?commentreply_id='+params[:commentreply_id], alert: "Reply cannot be empty." }
                    format.json { render :json => {:status => 400, :error => "Bad Request", :message => "Content cannot be empty"}, :status => 400 }
                  end
                elsif @reply.commentreply_id.blank?
                  # aquest missatge no es veu
                  format.json { render :json => {:status => 400, :error => "Bad Request", :message => "commentreply_id cannot be empty"}, :status => 400 }
                else
                  format.html { render :new, status: :unprocessable_entity }
                  format.json { render json: @reply.errors, status: :unprocessable_entity }
                end
              end
          end
        end
      else
      format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Missing authentication"}, :status => 401 }
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
    for re in Reply.where(commentreply_id: @reply.id)
      
      for reply in Reply.where(commentreply_id: re.id)
        reply.destroy
      end
    
      re.destroy
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
