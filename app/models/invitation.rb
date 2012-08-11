class Invitation < ActiveRecord::Base

    validates_presence_of :email
    #validates_uniqueness_of :email

    before_create { generate_token(:verify_email_token)}
    
    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while Invitation.exists?(column => self[column])
    end
    
end
