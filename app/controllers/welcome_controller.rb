class WelcomeController < ApplicationController

    def index
        #@signup = Signup.new
        @invitation = Invitation.new
        if current_user 
            redirect_to person_path(current_user.person)
        end
    end


end
