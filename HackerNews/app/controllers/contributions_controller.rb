class ContributionsController < ApplicationController
  before_action :set_contribution, only: %i[ show edit update destroy ]

  # GET /contributions or /contributions.json
  def index
    @contributions = Contribution.all.order(created_at: :desc)
  end
  
  def newest
    @contributions = Contribution.all.order(created_at: :desc)
  end

  # GET /contributions/1 or /contributions/1.json
  def show
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
    if @contribution.url.empty?
      @contribution.tipus = "ask"
    else
      @contribution.tipus = "url"
    end

    respond_to do |format|
      if @contribution.save
        format.html { redirect_to @contribution, notice: "Contribution was successfully created." }
        format.json { render :show, status: :created, location: @contribution }
      else
        format.html { redirect_to Contribution.find_by(url: @contribution.url) }
        format.json { render :show, location: @contribution }
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
