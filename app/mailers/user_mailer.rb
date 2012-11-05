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

    def mobile_invitation_confirmation(current_user, invitation)
        @requestor_email = current_user
        @invitation = invitation
        mail to: invitation.email, :subject => "ePetfolio Invitation"
    end

    #  called by Person_Controller.update - mobile app did Verify My Email
    def verify_email_mobile_user(person)
        @person = person
        mail to: @person.email, :subject => "ePetfolio Email Verification"
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
