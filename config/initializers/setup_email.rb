
ActionMailer::Base.smtp_settings = {
  :address              => 'smtp.gmail.com',
  :port                 => 587,
  #:domain               => 'epetfolio.com',
  :user_name            => 'epetfolio@gmail.com',
  :password             => 'fluffyfid0',
  :authentication       => :plain,
  :enable_starttls_auto => true
}


#ActionMailer::Base.default_url_options[:host] = "www.epetfolio.com"
ActionMailer::Base.default_url_options[:host] = "localhost:3000"
ActionMailer::Base.raise_delivery_errors = true

require 'development_mail_interceptor' 
ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?



