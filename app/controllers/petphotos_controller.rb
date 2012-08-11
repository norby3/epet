class PetphotosController < ApplicationController

    def index
    end

    def new
        @pet = Pet.find params[:pet_id]
        @petphoto = @pet.petphotos.build
    end

    def create
        @pet = Pet.find(params[:pet_id])
        @petphoto = @pet.petphotos.new(params[:petphoto])

        respond_to do |format|
            if @petphoto.save
                format.html { redirect_to pets_path, notice: 'Photo added.' }
                #format.json { render json: @pet, status: :created, location: @pet }
            else
                format.html { render action: "new" }
                #format.json { render json: @pet.errors, status: :unprocessable_entity }
            end
        end
    end

end

