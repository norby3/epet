class PersonConnection < ActiveRecord::Base
    # for reference: http://stackoverflow.com/questions/2168442/many-to-many-relationship-with-the-same-model-in-rails
    belongs_to :person_a, :class_name => :Person
    belongs_to :person_b, :class_name => :Person
    
end
