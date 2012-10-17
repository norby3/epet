class UsersController < ApplicationController

    respond_to :html, :json
    
    def new
        if (params[:email])
            @user = User.new :email => params[:email]
        else 
            @user = User.new
        end
        respond_with(@user)
    end
  
    def create
        @user = User.new(params[:user])
        if @user.save
            #redirect_to root_url, :notice => "Signed up!"
            # login the user
            cookies[:auth_token] = @user.auth_token
            #redirect_to @user.person, :notice => "Signed up!"

            logger.debug("trying to redirect to new person's profile")
            redirect_to edit_person_path(@user.person), :notice => "Signed Up!  Optional profile information"
        else
            render "new"
        end
    end

    def edit
        #@user = User.find_by_verify_email_token!(params[:id])
        @user = User.find(params[:id])
    end

    def update
        @user = User.find(params[:id])
        #if @user.verify_email_sent_at < 12.hours.ago
        #  redirect_to new_password_reset_path, :alert => "Password reset has expired."
        #elsif @user.update_attributes(params[:user])
        #params[:user][:status] = 'active'
        if @user.update_attributes(params[:user])
            # after the user has verified their email and chosen a pwd, then they are logged in by setting cookie
            cookies[:auth_token] = @user.auth_token
            redirect_to root_url, :notice => "Password has been set! And you are logged in."
        else
          render :edit
        end
    end
    # mobile API ajax requests
    # create user, person, session?
    # json response
    def create_mobile
        @user = User.new(params[:user])
        @user.timezone = params[:timezone]
        if @user.save
            #render :json => @user
            respond_with(@user)
        else 
            logger.debug("errror creating user in API")
        end
    end
end







