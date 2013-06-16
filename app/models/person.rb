class Person < ActiveRecord::Base
    
    belongs_to :user
    has_many :addresses, :as => :addressable
    
    has_many :caretakers
    has_many :pets, :through => :caretakers
    has_many :devices
    accepts_nested_attributes_for :devices
    accepts_nested_attributes_for :addresses
    
    before_create { generate_upid }
    before_update { generate_token(:comments) }
    
    # reference: http://stackoverflow.com/questions/2168442/many-to-many-relationship-with-the-same-model-in-rails
    has_many(:person_connections, :foreign_key => :person_a_id, :dependent => :destroy)
    has_many(:reverse_person_connections, :class_name => :PersonConnection,
         :foreign_key => :person_b_id, :dependent => :destroy)
    #has_many :persons, :through => :person_connections, :source => :person_b
    has_many :familyandfriends, :through => :person_connections, :source => :person_b
    
    # 2013-05-22
    has_many :peeps, :through => :person_connections, :source => :person_b

    def generate_upid
        self.upid = SecureRandom.urlsafe_base64
    end

    def generate_token(column)
        if self.status.eql?('verifying')
            self[column] = SecureRandom.urlsafe_base64
        end
    end

    def as_json(options={})
        #super(:include => :petphotos)
        super( :only => [:first_name, :last_name, :email, :mobile_phone, :status, :id, :upid, :image, :timezone, :personas],
            :include => { :pets => { :only => [:id, :name, :breed, :gender, :weight, :birthdate], 
                                  :include => { :petphotos => { :only => [:id, :image] }}},
                          :addresses => { :only => [:id, :line1, :line2, :locality, :region, :postcode] }
                        } )
    end
    
end




