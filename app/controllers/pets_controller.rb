class PetsController < ApplicationController

        
  # GET /pets
  # GET /pets.json
  def index
      #@pets = Pet.all
      #@person = Person.find(params[:person_id])
      @person = current_user.person
      @pets = @person.pets

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pets }
    end
  end

  # GET /pets/1
  # GET /pets/1.json
  def show
    @pet = Pet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pet }
    end
  end

  # GET /pets/new
  # GET /pets/new.json
  def new
    #@pet = Pet.new
    #@person = Person.find(params[:person_id])
    #@current_user = current_user
    #@person = current_user.person
    #logger.debug("@person.email = " + @person.email)

    @pet = Pet.new
    #@petphoto = @pet.petphotos.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pet }
    end
  end

  # GET /pets/1/edit
  def edit
    @pet = Pet.find(params[:id])
  end

  # POST /pets
  # POST /pets.json
  def create
    @pet = Pet.new(params[:pet])
    if (params[:person_id])
        @person= Person.find(params[:person_id])
    else 
        @person = current_user.person
    end
    @pet.caretakers.new(:person_id => @person.id, :primary_role => 'Owner')

    #@picture = @pet.picture.new(params[:picture])    

    respond_to do |format|
      if @pet.save
        #format.html { redirect_to @pet, notice: 'Pet was successfully created.' }
        format.html { redirect_to @person, notice: 'Pet added.' }
        format.json { render json: @pet, status: :created, location: @pet }
      else
        format.html { render action: "new" }
        format.json { render json: @pet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pets/1
  # PUT /pets/1.json
  def update
    @pet = Pet.find(params[:id])

    respond_to do |format|
      if @pet.update_attributes(params[:pet])
        format.html { redirect_to @pet, notice: 'Pet was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pets/1
  # DELETE /pets/1.json
  def destroy
    @pet = Pet.find(params[:id])
    @pet.destroy

    respond_to do |format|
      format.html { redirect_to pets_url }
      format.json { head :no_content }
    end
  end
  
  # call via ajax GET from mobile apps - return a UL list of pets
  # via erb view, sending back HTML snippet to be inserted into the mobile page
  def mobile_pets_list
    @person= Person.find(params[:person_id])
    @pets = @person.pets
    
    # renders views/pets/mobile_pets_list.html.erb
    render :layout => false
  end
  def mobile_pet
    #@pet = Pet.includes(:petphotos).find(params[:pet_id]).order("petphotos.created_at DESC").first
    @pet = Pet.includes(:petphotos).find(params[:pet_id])

    if (@pet.petphotos.length > 0)
      logger.debug("image = " + @pet.petphotos[0].image)
    end 
    
    # renders views/pets/mobile_pet.html.erb
    render :layout => false
  end
  
end




