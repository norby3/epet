class Person < ActiveRecord::Base
    
    belongs_to :user
    has_many :addresses, :as => :addressable

    has_many :caretakers
    has_many :pets, :through => :caretakers

    # reference: http://stackoverflow.com/questions/2168442/many-to-many-relationship-with-the-same-model-in-rails
    has_many(:person_connections, :foreign_key => :person_a_id, :dependent => :destroy)
    has_many(:reverse_person_connections, :class_name => :PersonConnection,
         :foreign_key => :person_b_id, :dependent => :destroy)
    #has_many :persons, :through => :person_connections, :source => :person_b
    has_many :familyandfriends, :through => :person_connections, :source => :person_b
    
end
