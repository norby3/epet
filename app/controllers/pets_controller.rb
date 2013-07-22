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
    #@pet = Pet.find(params[:id])
    @pet = Pet.includes(:petphotos).find(params[:id])

    if (@pet.petphotos.length > 0)
      logger.debug("image = " + @pet.petphotos[0].image)
    end 

    respond_to do |format|
      format.html # show.html.erb
      #format.json { render json: @pet }
      format.json { render json: {:pet => @pet, :petphoto => @pet.petphotos[0] } }
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
    if (params[:person_upid])
        @person= Person.find_by_upid(params[:person_upid])
    else 
        @person = current_user.person
    end
    @pet.caretakers.new(:person_id => @person.id, :primary_role => 'Owner')
    
    #@picture = @pet.picture.new(params[:picture])    

    respond_to do |format|
      if @pet.save
          # for each of owner's family & friends add a row as pet caretaker
          @person.person_connections.each do |fandf|
              famfrnd = Person.find(fandf.person_b_id)
              famfrnd.caretakers.build(:pet_id => @pet.id, :primary_role => fandf.category, :status => 'active', :started_at => Time.now)
              famfrnd.save
          end
          # lil unorthodox to return caretaker + pet + petphoto but is what the petowner app needs
          @pets = Caretaker.includes(:pet).where(:person_id => @person.id)    
          #format.html { redirect_to @pet, notice: 'Pet was successfully created.' }
          format.html { redirect_to @person, notice: 'Pet added.' }
          #format.json { render json: @pet, status: :created, location: @pet }
          format.json { render json: @pets }
      else
          format.html { render action: "new" }
          format.json { render json: @pet.errors, status: :unprocessable_entity }
      end
    end
  end

    # this is for PetOwner app "add pet" screen
    # adding a pet can be lil tricky - need to add caretaker role for the 'owner' and all the f&f and pet_pros
    def create2
        @person= Person.find_by_upid(params[:person_upid])
        @pet = Pet.new(params[:pet])

        respond_to do |format|
            if @pet.save
                @pp = @person.as_json(:include => :addresses)
                @pp[:pets] = Pet.joins(:caretakers).includes(:petphotos).where("caretakers.primary_role = 'Owner' and caretakers.person_id = ?", @person.id).all.as_json(:include => :petphotos)

                if @person.status.eql? "active mobile"
                    # add pet to related peeps (f&f, pet_pros)
                    @person.person_connections.each do |fandf|
                        famfrnd = Person.find(fandf.person_b_id)
                        if fandf.category.eql? 'Spouse-Partner'
                            prim_role = 'Owner'
                        else   # category in Family, Friend, Dog Walker
                            prim_role = fandf.category
                        end
                        famfrnd.caretakers.build(:pet_id => @pet.id, :primary_role => prim_role, :status => 'active', :started_at => Time.now)
                        famfrnd.save
                    end
                end

                format.json { render json: @pp }
            else 
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
    @person= Person.includes(:caretakers, :pets).find(params[:person_id])
    #@pets = @person.pets.includes(:caretakers)
    
    # renders views/pets/mobile_pets_list.html.erb
    render :layout => false
  end

  def mobile_pet
    #@pet = Pet.includes(:petphotos).find(params[:pet_id]).order("petphotos.created_at DESC").first
    @pet = Pet.includes(:petphotos).find(params[:pet_id])

    if (@pet.petphotos.length > 0)
      logger.debug("image = " + @pet.petphotos[0].image)
    end 

    render json: {:pet => @pet, :petphoto => @pet.petphotos[0] }
  end
  
end




