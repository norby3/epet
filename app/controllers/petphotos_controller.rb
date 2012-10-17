class PetphotosController < ApplicationController

    require 'open-uri'

    def index
    end

    def new
        @pet = Pet.find params[:pet_id]
        @petphoto = @pet.petphotos.build
    end

    def create
        if params[:pet_id]
            @pet = Pet.find(params[:pet_id])
            @petphoto = @pet.petphotos.new(params[:petphoto])
        elsif params[:dogwalk_id]
            @dogwalk = Dogwalk.find(params[:dogwalk_id])
            @petphoto = @dogwalk.build_petphoto(params[:petphoto])
        end
        logger.debug("params[:petphoto][:image] = " + params[:petphoto][:image] )
        logger.debug("@petphoto.image = " + @petphoto.image )

        respond_to do |format|
            if @petphoto.save
                format.html { redirect_to pets_path, notice: 'Photo added.' }
                #format.json { render json: @pet, status: :created, location: @pet }
                format.json { render json: @petphoto }
            else
                format.html { render action: "new" }
                format.json { render json: @pet.errors, status: :unprocessable_entity }
            end
        end
    end

    #  do better
    #  find the best photos to show this pet owner
    def mobile_photo_gallery
        @person = Person.new(params[:person_id])
        @photos = []
        @photos << "861F897A-43F2-41AF-AAD6-B55BA324E7A3-20120925035426.jpg"
        @photos << "861F897A-43F2-41AF-AAD6-B55BA324E7A3-20120926102340.jpg"
        @photos << "861F897A-43F2-41AF-AAD6-B55BA324E7A3-20120926105814.jpg"
        render :layout => false
    end

    # run the query on petphotos table
    # loop thru each image 
    #   retrieve the image from s3
    #   get the exif data for the image
    #   save the lat/lng/alt/etc to the table
    #   reverse geocode the address using google
    # end loop    
    # select image, created_at from petphotos where dogwalk_id IS NOT NULL and latitude IS NULL order by created_at desc;
    def getExifDataForS3Photos 
        s3host = "https://s3.amazonaws.com/epetfolio/uploads/dogwalks/"
        @images = Petphoto.order("created_at desc").where("dogwalk_id IS NOT NULL and latitude IS NULL")
        @images.each do |image|
            
            EXIFR::JPEG.new('IMG_6841.JPG').exif?
            EXIFR::JPEG.new('enkhuizen.jpg').gps.latitude       # => 52.7197888888889
            EXIFR::JPEG.new('enkhuizen.jpg').gps.longitude      # => 5.28397777777778
        end
    end
end

