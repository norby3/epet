class Pet < ActiveRecord::Base

    #belongs_to :person
    has_many :caretakers
    has_many :people, :through => :caretakers
    has_many :petphotos
    accepts_nested_attributes_for :petphotos
    accepts_nested_attributes_for :caretakers

    has_many :dogwalks
    
    validates_presence_of :name

    # for json rendering
    def as_json(options={})
        super(:include => :petphotos)
    end

end
