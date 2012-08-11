class UserMailer < ActionMailer::Base
    default from: "norby@epetfolio.com"


    def signup_confirmation(signup)
        @signup = signup
        
        mail to: signup.email, :subject => "ePetfolio Sign Up Confirmation"
    end

    def invitation_confirmation(current_user, invitation)
        @current_user = current_user
        @invitation = invitation
        mail to: invitation.email, :subject => "ePetfolio eMail Confirmation"
    end


  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
      @user = user
    @greeting = "Hi"

    mail to: "to@example.org"
  end
  
  
end
