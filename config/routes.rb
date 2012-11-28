Epet5::Application.routes.draw do

  post "create_invited_mobile_user" => "people#create_invited_mobile_user"
  post "accept_invite" => "invitations#accept_invite"

  # trying to setup redirect to open the mobile app
  # the operating system should see PetOwner:// and then want to open PetOwneriOS
  #match "friendsfamily/:email/:token" => redirect("PetOwner://epetfolio/%{email}/%{token}")
  match "friendsfamily/:token" => redirect("PetOwner://epetfolio/%{token}")
  #match "friendsfamily/:token" => "invitations#accept_invitation_new_user"
  match "friendsfamily2/:token" => "invitations#accept_invitation_existing_user"

  # these did not work...
  #  match "friendsfamily/:verify_email_token" => redirect {|params| "PetOwner://#{params[:verify_email_token]}" }
  #match "friendsfamily/:token" => redirect("PetOwner://#{token}")
  #match "friendsfamily/:token" => redirect {|params| "PetOwner://epetfolio/#{params[:token]}" }
  #match "friendsfamily/:token" => redirect( url_for("PetOwner://epetfolio/%{token}", :port => nil) )

  # mobile API Pet Owner - ajax requests from jquery-mobile forms
  match "verify_email_mobile_user" => "people#verify_email_mobile"
  #post "device_app_init" => "users#create_mobile"
  post "new_mobile_user" => "people#create_mobile"
  get "checkForMobileUserUpdates" => "people#mobile_user_updates"

  get "report_cards" => "dogwalks#dogwalks_mobile"
  match "dogwalk_mobile/:id" => "dogwalks#show_mobile"

  get "mobile_photo_gallery" => "petphotos#mobile_photo_gallery"
#  get "avoid_dogwalker_scams" => "petphotos#avoid_dogwalker_scams"   - moved to mobile_user_updates

  get "measure/hop"
  get "family_friends" => "invitations#family_friends_mobile"
  post "ff_invite" => "invitations#create_mobile"
  
  #match "mperson" => "people#show2"
  match "mperson" => "people#show3"
  #match "/people/:auth_token" => "people#show2"
  match "hop" => "measure#hop"
  
  match "mobile_pets" => "pets#mobile_pets_list"
  match "mobile_pet" => "pets#mobile_pet"

#  post "add_pet" => ""

  resources :dogwalks do
    resources :petphotos
  end

  get "person_connection/create"

  get "person_connection/delete"

  get "email_invite" => "invitations#verify_email", :as => "email_invite"

  resources :invitations

  resources :people do 
      resources :addresses
  end

  resources :pets do 
      #resources :pictures, :addresses, :dogwalks
      resources :petphotos
  end

  get "sessions/new"

  get "welcome/index"
  get "welcome/dwguide"

  get "users/new"

  get "logout" => "sessions#destroy", :as => "logout"
  get "login" => "sessions#new", :as => "login"
  get "signup" => "users#new", :as => "signup"

  # get "signup_verify" => "users#verify_email", :as signup_verify

#  root :to => "home#index"
  resources :users
  resources :sessions

  #get "email_verification/new"
#  resources :email_verification   # no model
  post "email_verification" => "email_verification#create"

  #get "password_resets/new"
  resources :password_resets      # no model


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
