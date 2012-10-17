class SignupController < ApplicationController
    def new
        @signup = Signup.new
    end

    def create
        @signup = Signup.new(params[:signup])
        @signup.ip_address = request.remote_ip
        @signup.verify_email_sent_at = Time.zone.now

        if @signup.save
            UserMailer.signup_confirmation(@signup).deliver
            redirect_to root_url, :notice => "Check your email inbox for instructions"
        else
            render "new"
        end
    end  

end
