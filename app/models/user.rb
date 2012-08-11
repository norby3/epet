class User < ActiveRecord::Base

    has_one :person
    has_secure_password
    validates_presence_of :email, :password, :password_confirmation
    validates_confirmation_of :password
    validates_uniqueness_of :email    

    before_create { generate_token(:auth_token) }
    after_create { create_corresponding_person }

    def send_password_reset
      generate_token(:password_reset_token)
      self.password_reset_sent_at = Time.zone.now
      save!
      UserMailer.password_reset(self).deliver
    end

    def send_verify_email
        logger.debug("start User.send_email_confirm")
        generate_token(:verify_email_token)
        logger.debug("User.send_email_confirm debug a")
        self.verify_email_sent_at = Time.zone.now
        save!
        UserMailer.signup(self).deliver
        
    end

    def generate_token(column)
        begin
            self[column] = SecureRandom.urlsafe_base64
        end while User.exists?(column => self[column])
    end
    
    def create_corresponding_person
        @person = self.create_person(:user_id => self.id.to_i, :email => self.email)
    end
    
end







