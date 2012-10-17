class DogwalksController < ApplicationController
  # GET /dogwalks
  # GET /dogwalks.json
  def index
    @dogwalks = Dogwalk.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dogwalks }
    end
  end

  # GET /dogwalks/1
  # GET /dogwalks/1.json
  def show
    @dogwalk = Dogwalk.find(params[:id])
    Time.zone = @dogwalk.timezone || 'America/New_York'
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dogwalk }
    end
  end

  # GET /dogwalks/new
  # GET /dogwalks/new.json
  def new
      @pet = Pet.find(params[:pet_id])
      @dogwalk = Dogwalk.new :pet_id => @pet.id, :person_id => current_user.person.id
      @dogwalk.build_petphoto

      respond_to do |format|
          format.html # new.html.erb
          format.json { render json: @dogwalk }
      end
  end

  # GET /dogwalks/1/edit
  def edit
    @dogwalk = Dogwalk.find(params[:id])
    @pet = @dogwalk.pet
    if @dogwalk.petphoto.blank?
        @dogwalk.build_petphoto
    end
  end

  # POST /dogwalks
  # POST /dogwalks.json
  def create
    @dogwalk = Dogwalk.new(params[:dogwalk])

    respond_to do |format|
      if @dogwalk.save
        #format.html { redirect_to @dogwalk, notice: 'Dogwalk was successfully created.' }
        format.html { redirect_to person_path(current_user.person.id), notice: "Dogwalk saved"}
        #format.json { render json: @dogwalk, status: :created, location: @dogwalk }
        format.json { render json: @dogwalk }
      else
        format.html { render action: "new" }
        format.json { render json: @dogwalk.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /dogwalks/1
  # PUT /dogwalks/1.json
  def update
    @dogwalk = Dogwalk.find(params[:id])

    if params[:save_send_button]
        logger.debug("save & send button")
        params[:dogwalk][:status] = 'done'
    end

    respond_to do |format|
      if @dogwalk.update_attributes(params[:dogwalk])
        #format.html { redirect_to @dogwalk, notice: 'Dogwalk was successfully updated.' }
        format.html { redirect_to person_path(current_user.person.id), notice: "Dogwalk saved"}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @dogwalk.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dogwalks/1
  # DELETE /dogwalks/1.json
  def destroy
    @dogwalk = Dogwalk.find(params[:id])
    @dogwalk.destroy

    respond_to do |format|
      format.html { redirect_to dogwalks_url }
      format.json { head :no_content }
    end
  end

  # find the pets for the param person
  # find all the ended dogwalks 
  def dogwalks_mobile 
      @person = Person.find(params[:person_id])
      logger.debug("pets: " + @person.pet_ids.to_s)
      #@dogwalks = Dogwalk.order("updated_at desc").where(:pet_id => @person.pet_ids, "stop IS NOT NULL")
      @dogwalks = Dogwalk.order("updated_at desc").where("pet_id = ? AND stop is not null", @person.pet_ids)
      render :layout => false
  end

  # show one dogwalk view only for mobile device
  def show_mobile
    @dogwalk = Dogwalk.find(params[:id])
    @dt = Time.parse(@dogwalk.petphoto.image_created_at) if @dogwalk.petphoto.image_created_at
    render :layout => false
  end
  
  
end
