class EmailVerificationController < ApplicationController

    def new
        
    end


    def create
        logger.debug("debug point a")
        user = User.find_by_email(params[:email])

        logger.debug("debug point b")
        if user
            logger.debug("debug point b1")
            user.send_password_reset
        elsif 
            user = User.new
            user.email = params[:email]
            user.password = "foobar"
            user.password_confirmation  = "foobar"
            user.status = 'pending verification'
            user.save!
            logger.debug("debug point b2")
            user.send_verify_email
        end
        logger.debug("debug point c")
        redirect_to root_url, :notice => "Email sent with instructions."
    end


end
