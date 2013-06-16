Epet5::Application.routes.draw do

  post 'dw_cancel' => 'dogwalks#cancel'                                  # 2013-06-15

  post "pet_pro_invite" => "invitations#pet_owner_inviting_dogwalker"    # 2013-04-23

  match "client_and_pets/:id" => "people#client_and_pets"
  match "my_pet_pros" => "people#my_pet_pros"
  match "clients_dogwalk/:id" => "invitations#clients_dogwalk"

  # added 2013-02-17  means dogwalker invited a client
  #match "dogwalker_invited/:email" => "invitations#dogwalker_invited"
  match "dogwalker_invited" => "invitations#dogwalker_invited"

  # redirect to open the mobile app
  # the operating system should recognize the custom URL PetOwner:// and open PetOwneriOS app
  #match "friendsfamily/:token" => redirect("PetOwner://epetfolio/%{token}")
  # adding some functionality to this request - try to prevent duplicate accept invites - controller will redirect
  match "friendsfamily/:token" => "invitations#preliminary_accept_invite"
  match "client_accepting_dogwalker_invitation/:token" => "invitations#preliminary_accept_invite"

  match "dogwalker_accepting_pet_owner_invitation/:token" => "invitations#preliminary_accept_invite"    # 2013-04-28

  post "accept_invite" => "invitations#accept_invite"

  match "verify_email_mobile_user" => "people#verify_email_mobile"

  post "new_mobile_user" => "people#create_mobile"
  get "checkForMobileUserUpdates" => "people#mobile_user_updates"
  get "checkForProMobileUserUpdates" => "people#pro_mobile_user_updates"
  get "checkForProMobileUserUpdates2" => "people#pro_mobile_user_updates2"    # 2013-05-06  called by DogWalker app
  
  get "report_cards" => "dogwalks#dogwalks_mobile"
  match "dogwalk_mobile/:id" => "dogwalks#show_mobile"
  get "pro_dogwalker_report_cards" => "dogwalks#pro_dogwalker_report_cards"

  get "mobile_photo_gallery" => "petphotos#mobile_photo_gallery"
#  get "avoid_dogwalker_scams" => "petphotos#avoid_dogwalker_scams"   - moved to mobile_user_updates

  get "measure/hop"
  get "family_friends" => "invitations#family_friends_mobile"
  post "ff_invite" => "invitations#create_mobile"
  post "dogwalker_inviting_client" => "invitations#dogwalker_inviting_client"
  
  #match "mperson" => "people#show2"
  match "mperson" => "people#show3"
  #match "/people/:auth_token" => "people#show2"
  match "hop" => "measure#hop"
  
  match "mobile_pets" => "pets#mobile_pets_list"
  match "mobile_pet" => "pets#mobile_pet"

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
