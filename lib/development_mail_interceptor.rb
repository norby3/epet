class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    message.to = "norbert.ryan3@gmail.com"
    message.cc = ""
  end
  
  # def self.delivered_email(message)
  #   logger.debug("delivered_email")
  #   sessn.logger.debug(message)
  # end
  
end