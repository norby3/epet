class Petphoto < ActiveRecord::Base

    # require 'open-uri'
    belongs_to :pet
    belongs_to :dogwalk
#    mount_uploader :image, ImageUploader

#    before_save :extract_exif_data

    # after_save :parse_exif_data
    # 
    # def parse_exif_data
    #     logger.debug "parse_exif_data start"
    #     if !self.image.blank? 
    #         logger.debug "parse_exif_data self.image = " + self.image
    #         s3host_prefix = "https://s3.amazonaws.com/epetfolio/uploads/dogwalks/"
    #         
    #         exif_info = EXIFR::JPEG.new(open(s3host_prefix + self.image))
    # 
    #     end
    # end



    def extract_exif_data
        #if !self.address.blank? && !self.latitude.blank? && !self.longitude.blank? 
        if self.address.blank? && !image.blank? 
            logger.debug("start extract_exif_data")
            logger.debug("session id = #{id}")
            logger.debug("image = #{image}")
            logger.debug("image.url = #{image.url}")
            logger.debug("image.current_path = #{image.current_path}")
            logger.debug("image.identifier = #{image.identifier}")
            #logger.debug("full path to image = #{Rails.root.join("public", image)}")
   
            logger.debug("extract_exif_data debug point a")
            #img = Magick::Image.read(image)[0] rescue nil
            #img = Magick::Image.read(Rails.root.join("public", image.url))[0]
            img = Magick::Image.read(image.current_path)[0]

            logger.debug("extract_exif_data debug point aa img = #{img}")

            return unless img
            self.image_created_at = img.get_exif_by_entry('DateTime')[0][1] rescue nil

            logger.debug("extract_exif_data debug point b")

            img_lat = img.get_exif_by_entry('GPSLatitude')[0][1].split(', ') rescue nil
            logger.debug("img_lat = #{img_lat}")
            img_lng = img.get_exif_by_entry('GPSLongitude')[0][1].split(', ') rescue nil
            logger.debug("img_lng = #{img_lng}")

            lat_ref = img.get_exif_by_entry('GPSLatitudeRef')[0][1] rescue nil
            logger.debug("lat_ref = #{lat_ref}")
            lng_ref = img.get_exif_by_entry('GPSLongitudeRef')[0][1] rescue nil
            logger.debug("lng_ref = #{lng_ref}")

            alt_ref = img.get_exif_by_entry('GPSAltitudeRef')[0][1] rescue nil
            logger.debug("alt_ref = #{alt_ref}")

            logger.debug("extract_exif_data debug point c")

            return unless img_lat && img_lng && lat_ref && lng_ref

            logger.debug("extract_exif_data debug point d")

            latitude = to_frac(img_lat[0]) + (to_frac(img_lat[1])/60) + (to_frac(img_lat[2])/3600)
            longitude = to_frac(img_lng[0]) + (to_frac(img_lng[1])/60) + (to_frac(img_lng[2])/3600)

            latitude = latitude * -1 if lat_ref == 'S'  # (N is +, S is -)
            longitude = longitude * -1 if lng_ref == 'W'   # (W is -, E is +)

            self.latitude = latitude
            self.longitude = longitude
            self.altitude = alt_ref
            
            logger.debug("extract_exif_data debug point e")

            if geo = Geocoder.search("#{latitude},#{longitude}").first
                #self.city = geo.city
                #self.state = geo.state
                #self.zipcode = geo.postal_code
                logger.debug("extract_exif_data debug point f")
                #self.address = geo.street + " " + geo.city
                self.address = geo.address(format = :full)
                logger.debug("geocoded address = #{self.address}")
            end
        logger.debug("end extract_exif_data")
        end    #  if 
    end

    def to_frac(strng)
        numerator, denominator = strng.split('/').map(&:to_f)
        denominator ||= 1
        numerator/denominator
    end


end
