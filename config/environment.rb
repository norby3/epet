# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Epet5::Application.initialize!

ActionMailer::Base.smtp_settings = {
  :address              => 'smtp.gmail.com',
  :port                 => 587,
  :domain               => 'epetfolio.com',
  :user_name            => 'epetfolio@gmail.com',
  :password             => 'fluffyfid0',
  :authentication       => :plain,
  :enable_starttls_auto => true
}
