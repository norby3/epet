class Invitation < ActiveRecord::Base

    # 2013-07-02 turning off validations 
    #validates_presence_of :email
   # validates_presence_of :email, :unless => :verify_email_token?

    #validates_presence_of :invitee_email
   #    validates_presence_of :invitee_email, :unless => :invitor_email?

    before_create { generate_token(:verify_email_token)}

    #scope :invited_clients_email, where(:status => 'invited', :category => 'Dog Walk Client'), select(:email)

    scope :invited_clients_email, where(:status => 'invited', :category => 'Dog Walk Client')

    def self.invitees(email)
       where('status = "invited" and category = "Dog Walk Client" and requestor_email =  ?', email)
    end
    
    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while Invitation.exists?(column => self[column])
    end
    
end
