class ApplicationController < ActionController::Base
    protect_from_forgery

    private

    def current_user
        @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
    end
    helper_method :current_user

    def authorize
      redirect_to login_url, :notice => "Please Login" if current_user.nil?
    end

    def find_some_pics
        if current_user.petphotos.count == 0
            @photos = Petphoto.where :id => [1,2,3,4]
        else 
            @photos = current_user.petphotos
        end
    end
    helper_method :find_some_pics

end
