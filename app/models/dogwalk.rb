class Dogwalk < ActiveRecord::Base
  belongs_to :pet
  belongs_to :person
  has_one :petphoto
  accepts_nested_attributes_for :petphoto

end
