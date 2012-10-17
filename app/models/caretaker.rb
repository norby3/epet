class Caretaker < ActiveRecord::Base
    belongs_to :person
    belongs_to :pet
    
    def self.owner
      where("caretakers.primary_role = 'Owner'")
    end    

    def self.family
      where("caretakers.primary_role = 'Family'")
    end   
     
    def self.friend
      where("caretakers.primary_role = 'Friend'")
    end    

    # is it true that in pet health care, the pet is the client, the person is the 'owner'?
    def self.client
      where("caretakers.primary_role = 'Client'")
    end    

end
