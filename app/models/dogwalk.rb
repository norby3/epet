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
          self.start = Time.at(self.start_as_millis.to_i/1000)
      end
      
      if !self.stop_as_millis.blank?
          self.stop = Time.at(self.stop_as_millis.to_i/1000)
      end
  end

  # for json rendering
  def as_json(options={})
      # super(:include => {:pet => {:include => :petphotos }})
      super(:include => [:petphoto, :person, {:pet => {:include => :petphotos }} ])
  end  

  # finished dogwalks - stop button has been pressed
  def self.finished
     where("status = 'active' AND stop IS NOT NULL")
  end

end




