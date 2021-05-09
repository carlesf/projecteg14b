class ContributionsController < ApplicationController
  before_action :set_contribution, only: %i[ show edit update destroy point unvote ]

  # GET /contributions or /contributions.json
  #Falta user_id i upvotedS -------------------------------------------------------
  def index
    respond_to do |format|
      if params[:user_id]
        @contributions = Contribution.where(user_id: params[:user_id]).order(created_at: :desc)
        format.html { @contributions }
        format.json { render json: @contributions.to_json(only: [:id, :title, :tipus, :url, :text, :created_at, :points, :user_id, :user]) }
      elsif params[:upvotedS]
        @votes = Vote.where(voter_id: current_user.id, votable_type: 'contribution').select(:votable_id)
        @contributions = Contribution.where(id: @votes)
        format.html { @contributions }
        format.json { render json: @contributions.to_json(only: [:id, :title, :tipus, :url, :text, :created_at, :points, :user_id, :user]) }
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
    @contribution = Contribution.new(contribution_params)
    @contribution.user = current_user.email
    @contribution.user_id = current_user.id
    if @contribution.url.empty?
      @contribution.tipus = "ask"
    else
      @contribution.tipus = "url"
    end

    respond_to do |format|
      if @contribution.save
        if @contribution.tipus == "url"
          Comment.create(content: @contribution.text, user_id: current_user.id, contr_id: @contribution.id)
          @contribution.text = ""
          @contribution.save
        end
        #No sabem fer-ho XD-----------------------------------------------------------------------------------
        format.html { redirect_to newest_contributions_path, notice: "Contribution was successfully created." }
        format.json { render :newest, status: :created, location: @contribution }
        
      else
        if @contribution.title.blank?
          format.html { redirect_to new_contribution_path, alert: "That's not a valid title." }
        elsif @contribution.errors.include?(:invalidurl)
          format.html { redirect_to new_contribution_path, alert: "That's not a valid URL." }
        else
          format.html { redirect_to Contribution.find_by(url: @contribution.url), notice:"Contribution NOT created." }
          format.json { render :show, location: @contribution }
        end
        # format.html { render :new, status: :unprocessable_entity }
        # format.json { render json: @contribution.errors, status: :unprocessable_entity }
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
      @contribution = Contribution.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def contribution_params
      params.require(:contribution).permit(:title, :url, :text, :tipus)
    end
end
