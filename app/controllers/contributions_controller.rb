class ContributionsController < ApplicationController
  #has_many :comments
  
  before_action :set_contribution, only: %i[ show edit update destroy point ]

  # GET /contributions or /contributions.json
  def index
    
    if params[:user_id]
      @contributions = Contribution.where(user_id: params[:user_id]).order(created_at: :desc)
    else 
      @contributions = Contribution.where(tipus: 'url').order(points: :desc)
    end

  end
  
  def newest
    @contributions = Contribution.all.order(created_at: :desc)
  end
  
  def ask
    @contributions = Contribution.all.order(points: :desc)
  end
  
  def point
    @contribution.points += 1
    @contribution.save
    # aqui peta tot i que suma els punts
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

  
  # GET /contributions/1 or /contributions/1.json
  def show
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
      # Crear comment associat a @contribution: comment.text = text | comment.user = contribution.user
    end

    respond_to do |format|
      if @contribution.save
        format.html { redirect_to newest_contributions_path, notice: "Contribution was successfully created." }
        format.json { render :show, status: :created, location: @contribution }
        
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
      params.require(:contribution).permit(:title, :url, :text)
    end
end
