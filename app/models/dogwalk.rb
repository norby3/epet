class Dogwalk < ActiveRecord::Base
  belongs_to :pet
  belongs_to :person
  has_one :petphoto
  accepts_nested_attributes_for :petphoto

  before_create { correct_times }
  before_update { correct_times }
  
  # millis is more reliable - start/stop based on timezone should be set close to the view as possible
  # goal here is to keep start/stop time reflecting UTC and not the local time of the mobile device
  def correct_times
      if !self.start_as_millis.blank?
          self.start = Time.at(start_as_millis/1000)
      end
      
      if !self.stop_as_millis.blank?
          self.stop = Time.at(stop_as_millis/1000)
      end
  end

end
