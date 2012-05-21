class UserToosController < ApplicationController
  # GET /user_toos
  # GET /user_toos.json
  def index
    @user_toos = UserToo.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_toos }
    end
  end

  # GET /user_toos/1
  # GET /user_toos/1.json
  def show
    @user_too = UserToo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_too }
    end
  end

  # GET /user_toos/new
  # GET /user_toos/new.json
  def new
    @user_too = UserToo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_too }
    end
  end

  # GET /user_toos/1/edit
  def edit
    @user_too = UserToo.find(params[:id])
  end

  # POST /user_toos
  # POST /user_toos.json
  def create
    @user_too = UserToo.new(params[:user_too])

    respond_to do |format|
      if @user_too.save
        format.html { redirect_to @user_too, notice: 'User too was successfully created.' }
        format.json { render json: @user_too, status: :created, location: @user_too }
      else
        format.html { render action: "new" }
        format.json { render json: @user_too.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_toos/1
  # PUT /user_toos/1.json
  def update
    @user_too = UserToo.find(params[:id])

    respond_to do |format|
      if @user_too.update_attributes(params[:user_too])
        format.html { redirect_to @user_too, notice: 'User too was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_too.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_toos/1
  # DELETE /user_toos/1.json
  def destroy
    @user_too = UserToo.find(params[:id])
    @user_too.destroy

    respond_to do |format|
      format.html { redirect_to user_toos_url }
      format.json { head :no_content }
    end
  end
end
