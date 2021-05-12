class ContributionsController < ApplicationController
  before_action :set_contribution, only: %i[ show edit update destroy point unvote ]
  skip_before_action :verify_authenticity_token

  # GET /contributions or /contributions.json
  #Falta user_id i upvotedS -------------------------------------------------------
  def index
    respond_to do |format|
      if params[:user_id]
        @user = User.where(id: params[:user_id])
        if @user.empty?
          format.json { render :json => {:status => 404, :error => "Not Found", :message => "No User with that user_id"}, :status => 404 }
        else
          @contributions = Contribution.where(user_id: params[:user_id]).order(created_at: :desc)
          format.html { @contributions }
          format.json { render json: @contributions.to_json(only: [:id, :title, :tipus, :url, :text, :created_at, :points, :user_id, :user]) }
        end
      elsif params[:upvotedS]
        if !User.where(id: params[:upvotedS]).empty?
          if request.headers['X-API-KEY']
            @apikey = request.headers['X-API-KEY']
            if !User.where(uid: @apikey).empty?
              @user = User.find_by(uid: @apikey)
              if params[:upvotedS].to_s == @user.id.to_s
                @votes = Vote.where(voter_id: @user.id, votable_type: 'contribution').select(:votable_id)
                @contributions = Contribution.where(id: @votes)
                format.json { render json: @contributions.to_json(only: [:id, :title, :tipus, :url, :text, :created_at, :points, :user_id, :user]) }
              else
                format.json { render :json => {:status => 403, :error => "Forbidden", :message => "Privilege not granted"}, :status => 403 }
              end
            else
              format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Incorrect authentication"}, :status => 401 }
            end
          else
            format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Missing authentication"}, :status => 401 }
            if !current_user.nil?
              @votes = Vote.where(voter_id: current_user.id, votable_type: 'contribution').select(:votable_id)
              @contributions = Contribution.where(id: @votes)
              format.html { @contributions }
            end
          end
        else
          format.json { render :json => {:status => 404, :error => "Not Found", :message => "No user with that user_id"}, :status => 404 }
        end
      elsif params[:type] == 'all'
        @contributions = Contribution.all.order(created_at: :desc)
        format.html { @contributions }
        format.json { render json: @contributions.to_json(only: [:id, :title, :tipus, :url, :text, :created_at, :points, :user_id, :user]) }
      elsif params[:type] == 'ask'
        @contributions = Contribution.where(tipus: 'ask').order(points: :desc)
        format.html { @contributions }
        format.json { render json: @contributions.to_json(only: [:id, :title, :tipus, :url, :text, :created_at, :points, :user_id, :user]) }
      else  # params[:type] == 'url'
        @contributions = Contribution.where(tipus: 'url').order(points: :desc)
        format.html { @contributions }
        format.json { render json: @contributions.to_json(only: [:id, :title, :tipus, :url, :text, :created_at, :points, :user_id, :user]) }
      end
    end
  end
  
  def newest
    @contributions = Contribution.all.order(created_at: :desc)
  end
  
  def ask
    @contributions = Contribution.where(tipus: 'ask').order(points: :desc)
  end
  
  def point
    @contribution.points += 1
    @contribution.save
          
    Vote.create(votable_id: @contribution.id, votable_type: 'contribution', voter_id: current_user.id)
    
    respond_to do |format|
      @view = params[:view]
      if @view == "index"
        format.html { redirect_to contributions_path }
      elsif @view == "newest" 
        format.html { redirect_to newest_contributions_path }
      elsif @view == "ask" 
        format.html { redirect_to ask_contributions_path }
      elsif @view == "show"
        format.html { redirect_to Contribution.find_by(id: @contribution.id) }
      end
    end 
  end

  def unvote
    @contribution.points -= 1
    @contribution.save
    
    respond_to do |format|

      @view = params[:view]
      if @view == "index"
        format.html { redirect_to contributions_path }
      elsif @view == "newest" 
        format.html { redirect_to newest_contributions_path }
      elsif @view == "ask" 
        format.html { redirect_to ask_contributions_path }
      elsif @view == "show"
        format.html { redirect_to Contribution.find_by(id: @contribution.id) }
      end
      
    end
          
    @vote = Vote.find_by(votable_id: @contribution.id, votable_type: 'contribution', voter_id: current_user.id)
    @vote.destroy
  end
  
  # GET /contributions/1 or /contributions/1.json
  def show
    
    #@contribution = Contribution.find(params[:id])
    @comment = Comment.new
    
    respond_to do |format|
      format.html { @contribution }
      
      if Contribution.where(id: params[:id]).empty?
        format.json { render :json => {:status => 404, :error => "Not Found", :message => "No Contribution with that ID"}, :status => 404 }
      else
        # Falta generar el json de la contribució amb tots els seus comentaris, replies, replies de replies, etc.
        format.json { render json: @contribution.to_json(only: [:id, :title, :tipus, :url, :text, :created_at, :points, :user_id, :user]) }
        @comments = Comment.find_by(contr_id: params[:id])
        Array(@comments).each do |comment|
          format.json { render json: comment.to_json(only: [:id, :content, :user_id, :contr_id, :created_at]) }
        end
      end
      
    end
    
  end

  # GET /contributions/new
  def new
    @contribution = Contribution.new
  end

  # GET /contributions/1/edit
  def edit
  end

  # POST /contributions or /contributions.json
  def create
    respond_to do |format|
      if request.headers['X-API-KEY'] || !current_user.nil?
        @apikey = request.headers['X-API-KEY']
        if !@apikey.nil? && User.where(uid: @apikey).empty?
          format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Incorrect authentication"}, :status => 401 }
        else
          @contribution
          if !current_user.nil?
            @contribution = Contribution.new(contribution_params)
            @contribution.user = current_user.email
            @contribution.user_id = current_user.id
          else
            @user = User.find_by(uid: @apikey)
            @contribution = Contribution.new
            @contribution.title = params[:title]
            @contribution.url = params[:url]
            @contribution.text = params[:text]
            @contribution.user = @user.email
            @contribution.user_id = @user.id
          end
          if @contribution.url.empty?
            @contribution.tipus = "ask"
          else
            @contribution.tipus = "url"
          end
          
          if @contribution.save
            if @contribution.tipus == "url"
              if !current_user.nil?
                Comment.create(content: @contribution.text, user_id: current_user.id, contr_id: @contribution.id)
              else
                Comment.create(content: @contribution.text, user_id: User.find_by(uid: @apikey).id, contr_id: @contribution.id)
              end
              @contribution.text = ""
              @contribution.save
              # Podriem enviar el comentari també
              format.json { render json: @contribution.to_json(only: [:id, :title, :tipus, :url, :text, :created_at, :points, :user_id, :user]), :status => 201 }
            else
              format.json { render json: @contribution.to_json(only: [:id, :title, :tipus, :url, :text, :created_at, :points, :user_id, :user]), :status => 201 }
            end
            #No sabem fer-ho XD-----------------------------------------------------------------------------------
            format.html { redirect_to newest_contributions_path, notice: "Contribution was successfully created." }
            
          else
            if @contribution.title.blank?
              format.html { redirect_to new_contribution_path, alert: "That's not a valid title." }
              format.json { render :json => {:status => 400, :error => "Bad Request", :message => "Title cannot be empty"}, :status => 400 }
            elsif @contribution.errors.include?(:invalidurl)
              format.html { redirect_to new_contribution_path, alert: "That's not a valid URL." }
              format.json { render :json => {:status => 400, :error => "Bad Request", :message => "URL must be valid"}, :status => 400 }
            else
              format.html { redirect_to Contribution.find_by(url: @contribution.url), notice:"Contribution NOT created." }
              format.json { render :json => {:status => 409, :error => "Conflict", :message => "URL already exists"}, :status => 409 }
            end
            # format.html { render :new, status: :unprocessable_entity }
            # format.json { render json: @contribution.errors, status: :unprocessable_entity }
          end
        end
      else
        format.json { render :json => {:status => 401, :error => "Unauthorized", :message => "Missing authentication"}, :status => 401 }
      end
    end
  end

  # PATCH/PUT /contributions/1 or /contributions/1.json
  def update
    respond_to do |format|
      if @contribution.update(contribution_params)
        format.html { redirect_to @contribution, notice: "Contribution was successfully updated." }
        format.json { render :show, status: :ok, location: @contribution }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @contribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contributions/1 or /contributions/1.json
  def destroy
    
    for comment in Comment.where(contr_id: @contribution.id)
      
      for reply in Reply.where(commentreply_id: comment.id)
        reply.destroy
      end
      
      comment.destroy
    end
    
    @contribution.destroy
    
    respond_to do |format|
      format.html { redirect_to contributions_url, notice: "Contribution was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contribution
      if !Contribution.where(id: params[:id]).empty?
        @contribution = Contribution.find(params[:id])
      end
    end

    # Only allow a list of trusted parameters through.
    def contribution_params
      params.require(:contribution).permit(:title, :url, :text, :tipus)
    end
    
end
