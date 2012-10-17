class Pet < ActiveRecord::Base

    #belongs_to :person
    has_many :caretakers
    has_many :people, :through => :caretakers
    has_many :petphotos
    has_many :dogwalks
    
end
