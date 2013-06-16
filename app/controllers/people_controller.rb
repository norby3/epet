class PeopleController < ApplicationController
    include FamilyAndFriends
    before_filter :authorize, :check_peep_connection, :only => [:show]

    respond_to :html, :json
    
  # GET /people
  # GET /people.json
  def index
    @people = Person.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @people }
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @person = Person.find(params[:id])
    @invitation = Invitation.new

    @doggie_report_cards = false
    @heroimage = nil
    #@heroimage = Petphoto.find(6)
    #if current_user.person.petphoto
    #    @heroimage = current_user.person.petphoto.first
    #end
    @invitations = Invitation.where(:requestor_email => current_user.email, :status => 'invited')

    respond_to do |format|
        format.html { render action: "show", :layout => "with_sidebar" }
        format.json { render json: @person }
    end
  end
  # def show2
  #   @user = User.find_by_auth_token(params[:auth_token])
  #   @person = @user.person
  #   render json: @person
  # end    
  def show3
    @person = Person.find_by_upid(params[:id])
    render json: @person
  end    

  # GET /people/new
  # GET /people/new.json
  def new
    @person = Person.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @person }
    end
  end

    # GET /people/1/edit
    def edit
        @person = Person.find(params[:id])
        respond_to do |format|
            format.html { render action: "edit", :layout => "with_sidebar" }
            format.json { render json: @person }
        end
    end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: 'Profile was saved.' }
        format.json { render json: @person, status: :created, location: @person }
      else
        format.html { render action: "new" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

    #  called by mobile devices during first time the app is used
    #  the user has just downloaded the app and installed it
    #  and they have started it for the first time
    #  create two objects Person and Device - Person object will be mostly blank
    def create_mobile
        @person = Person.new(params[:person])
        @person.status = "new mobile"
        # device.name deprecated in phonegap
        #@person.first_name = @person.devices[0].name.split(/\b/)[0]
        #@person.last_name = @person.devices[0].name.split(/\b/)[2]
        # if @person.personas.eql? 'Pro_Dog_Walker'
        #     # create person_connection to Ben Franklin
        #     @benf = Person.where(:last_name => 'Franklin', :first_name => 'Ben', :mobile_phone => '(215) 123-4567').first
        #     @person.person_connections.build(:person_a_id => self, :person_b_id => @benf, :category => 'Dog Walker Sample')
        #     # create caretaker for Ben Franklin's pet Fido
        #     @person.caretakers.build(:pet_id => @benf.pets[0].id, :primary_role => 'Dog Walker Sample', :started_at => Time.now)
        # end

        if @person.save
            if @person.personas.eql? 'Pro_Dog_Walker'
                @benf = Person.where(:last_name => 'Franklin (sample)', :first_name => 'Ben', :mobile_phone => '(215) 123-4567').first
                logger.debug("@benf.id = " + @benf.id.to_s)
                @person.person_connections.build(:person_a_id => @person.id, :person_b_id => @benf.id, :category => 'Dog Walker Sample')
                # create caretaker for Ben Franklin's pet Fido
                @person.caretakers.build(:pet_id => @benf.pets[0].id, :primary_role => 'Dog Walker Sample', :started_at => Time.now)
                @person.save
                render json: {:person       => @person,
                              :clients      => @benf
                             },
                      :layout => false
            else 
                render json: @person
            end
        else
            render json: @person.errors, status: :unprocessable_entity
        end
    end
  
  # ajax json POST request - called by js function initInvitedFamilyFriend()
  # this is a kind of special multi-model create b/c the person has been invited
  # called by mobile device - this user was invited by f&f to join
  # they have clicked a custom URL in the email invitation
  # lot to do here: create Person, Device, Caretaker, Person_Connection, update Invitation,
  # status = "active mobile"
  # expecting: Invitation.verify_email_token, all Device fields
  def create_invited_mobile_user 
     puts "create_invited_mobile_user - start"
     #  find the invitation
     @invitation = Invitation.find_by_verify_email_token(params[:verify_email_token])
     #  update the invitation
     @invitation.update_attributes(:status => "accepted")
     puts "create_invited_mobile_user - done invitation.update_attributes "
     
     @invitor = Person.find_by_email(@invitation.requestor_email)
     #  create the person & device
     @person = Person.new(params[:person])
     #@person.first_name = @person.devices[0].name.split(/\b/)[0]
     @person.email = @invitation.email
     @person.status = "active mobile"

     #  create the first person_connection 
     @person.person_connections.build(:person_a_id => self, :person_b_id => @invitor.id,
         :category => @invitation.category, :invitation_id => @invitation.id, :status => 'active')

     #  create the caretaker(s) loop thru each pet
     puts "create_invited_mobile_user - next step is pets each "
     @invitor.pets.each do |pet|
         puts "create_invited_mobile_user - each pet - pet.id = " + pet.id.to_s
         @person.caretakers.build(:pet_id => pet.id, :person_id => @person.id, :started_at => Time.now)
          # t.string :primary_role  t.string :secondary_role
     end 
     #  return person as json
     puts "create_invited_mobile_user - next step is person.save "
     if @person.save
       #  create the second person_connection - reverse of previous
       @invitor.person_connections.build(:person_a_id => self, :person_b_id => @person.id, 
                :category => @invitation.category, :invitation_id => @invitation.id, :status => 'active')
       @invitor.save
       puts "create_invited_mobile_user - save - render end"
       render json: @person
     else
       puts "create_invited_mobile_user - save - error"
       render json: @person.errors, status: :unprocessable_entity
     end
  end

  # PUT /people/1
  # PUT /people/1.json
  # edit_profile form in pet owner app
  # do betters: 
  #    keep count of # of verify_email requests
  def update
    @person = Person.find(params[:id])
    # support for the mobile app "Verify My Email"
    #logger.debug("params[:person][:email] = " + params[:person][:email] + " status = " + @person.status)
    # if params[:person][:email] && @person.status == "new mobile"
    if params[:person][:email] && params[:verify_email].eql?('request')
      @person.status = "verifying"
    end
    respond_to do |format|
      if @person.update_attributes(params[:person])
          if @person.status.eql?("verifying")
              UserMailer.verify_email_mobile_user(@person).deliver 
          end
          format.html { redirect_to @person, notice: 'Profile was saved.' }
          #format.json { head :no_content }
          format.json { render json: {:person => @person, :address => @person.addresses[0]} }
      else
        format.html { render action: "edit" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end
  
  #  called when user clicks on link in their email
  def verify_email_mobile
      @person = Person.find_by_comments(params[:id])
      if @person
        @person.status = 'active mobile'
        @person.save 
      end
      #render html  (first iteration sent to browser page) 
      # 2nd iteration sends redirect with custom URL PetOwner://?id=token
      # that should re-open the app - assuming they did these steps from their mobile phone
      #  routes.rb for similar use case --> redirect("PetOwner://epetfolio/%{token}")
      if @person.personas.eql?('Pro_Dog_Walker')
          redirect_to "DogWalker://epetfolio/email_verified"
      else
          redirect_to "PetOwner://epetfolio/email_verified"
      end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end

  # 1. if the mobile user verified their email - status = "active mobile"
  #  find all people & pets & related photos
  # no view or html - returns json 
  #  list of family email addresses & person.ids  
  #     @family_emails
  #  list of friends email addresses & person.ids
  #     @friends_emails
  #  list of image file names on s3
  #     @photos
  def mobile_user_updates
      # original before adding addresses
      @person = Person.find_by_upid(params[:id])
      
      # didn't work 
      #@person = Person.includes(:addresses).find_by_upid(params[:id]).order('addresses.updated_at desc')
      @address = @person.addresses.last

      @pets = Caretaker.includes(:pet).where(:person_id => @person.id)            
      logger.debug("@pets.empty? = " + @pets.empty?.to_s)
      if @pets.empty? 
          @pets = []
      end
      
      #@partners = []
      # # no moralizing - if there are more than one partners so be it
      # @partner_connections = @person.person_connections.where(:category => 'Spouse-Partner', :status => 'active')      
      # @partner_connections.each do |pt|
      #     partn = Person.find(pt.person_b_id)
      #     #@partners << { partn.email => partn.id }
      #     @partners << { 'email' => partn.email, 'id' => partn.id }
      # end
      @partners = []
      @family = []
      @friends = []
      @pet_pros = []
#      @person.person_connections.each do |ff|
      @person.person_connections.where(:status => 'active').each do |connection|
          other_person = Person.find(connection.person_b_id)
          logger.debug("other_person email = #{other_person.email} and id = #{other_person.id}")
          if connection.category.eql?('Spouse-Partner') 
              @partners << { 'category' => connection.category, 'email' => other_person.email, 'id' => other_person.id }
          elsif connection.category.eql?('Family')
              @family << { 'category' => connection.category, 'email' => other_person.email, 'id' => other_person.id }
          elsif connection.category.eql?('Friend')
              @friends << { 'category' => connection.category, 'email' => other_person.email, 'id' => other_person.id }
          elsif connection.category.eql?('Dog Walker')
              @pet_pros << { 'category' => connection.category, 'email' => other_person.email, 'id' => other_person.id }
          end
      end
      logger.debug("@pet_pros.size = #{@pet_pros.size}")
      logger.debug("@family.size = #{@family.size}")
      logger.debug("@friends.size = #{@friends.size}")
      logger.debug("@partners.size = #{@partners.size}")
      
      # people invited but who have not yet accepted
      @invited = Invitation.where(:requestor_email => @person.email, :status => 'invited')

      # a list of pet_ids where chistine is (f&f) caretaker
      @pet_ids = Caretaker.where(:person_id => @person.id).uniq.pluck(:pet_id)
      #logger.debug("@pet_ids = " + @pet_ids.to_s)
      
      # always want a set of photos for the user to see
      @photos = ['sample/00.png', 'sample/01.png', 'sample/02.png', 'sample/03.png', 'sample/04.png', 'sample/05.png',
        'sample/06.png', 'sample/07.png', 'sample/08.png', 'sample/09.png', 'sample/10.png', 'sample/11.png']
      
      logger.debug "@pet_ids.size = #{@pet_ids.size}"
      if @pet_ids.size > 0
          # if there are any real photos, add them starting at beginning of the array
          #@photos = Petphoto.where(:pet_id => @pet_ids).order("created_at DESC").uniq.pluck(:image)
          petphotos = Petphoto.where(:pet_id => @pet_ids).order("created_at DESC").uniq(:image)
          x = 0
          logger.debug "petphotos size = " + petphotos.size.to_s
          if petphotos && petphotos.size > 0
              petphotos.each do |p|
                  @photos[x] = "petphotos/" + p.image
                  logger.debug "adding real pet photo - x = #{x} "
                  x += 1
              end
          end
      end

      # getting dogwalks for this person for any of this person's pet(s)
      # why the OR ?  because this person might have walked a family&friend dog
      #
      #@report_cards = Dogwalk.order("updated_at desc").where("pet_id IN (?) AND stop IS NOT NULL", @pets)
      @report_cards = Dogwalk.order("updated_at desc").where("(person_id = ? OR pet_id IN (?)) AND stop IS NOT NULL AND status = 'active'", @person.id, @pets)
      # @dogwalks = Dogwalk.order("updated_at desc").where("pet_id IN (?) AND stop IS NULL", @pets)
      @dogwalks = Dogwalk.order("updated_at desc").where("(person_id = ? OR pet_id IN (?)) AND stop IS NULL AND status = 'active'", @person.id, @pets)
      
      render json: {:person       => @person, 
                    :address      => @address, 
                    :partners     => @partners,
                    :family       => @family, 
                    :friends      => @friends, 
                    :invited      => @invited,
                    #:pets         => @pets.to_json(:include => {:pet => {:include => :petphotos}}),
                    :pets         => @pets,              # uses as_json in models Caretaker and Pet
                    :photos       => @photos, 
                    :report_cards => @report_cards, 
                    :dogwalks     => @dogwalks,
                    :pet_pros     => @pet_pros },
            :layout => false
  end

  # if the pro mobile user verified their email - status = "active mobile"
  #  find all Clients (people & pets) & related photos
  # no view or html - returns json 
  #  list of image file names on s3
  #     @photos
  def pro_mobile_user_updates
      logger.debug "pro_mobile_user_updates start"
      @person = Person.find_by_upid(params[:id])
      
      @clients = []
      @person.person_connections.each do |pc|
          #other_person = Person.find(pc.person_b_id)
          @other_person = Person.includes({:pets => :petphotos }, :addresses).find(pc.person_b_id)
          #logger.debug("other_person email = #{@other_person.email} and id = #{@other_person.id}")
          if pc.category.eql?('Dog Walk Client')
              #@clients << { other_person.email => other_person.id }
              @clients << @other_person
          end
      end
      logger.debug("@clients.size = #{@clients.size}")

      @invitations = Invitation.select(:email).where(:requestor_email => @person.email, :status => 'invited')
      logger.debug("@invitations = " + @invitations.to_json)    
      # a list of pet_ids where chistine is (f&f) caretaker
      #  ????
      #@pets = Caretaker.where(:person_id => @person.id).uniq.pluck(:pet_id)
      #logger.debug("@pets = " + @pets.to_s)
      #logger.debug "@pets.size = #{@pets.size}"
      #render json: {:person => @person, :clients => @clients, :pets => @pets }, :layout => false
      logger.debug "@clients = " + @clients.to_json(:only => [:first_name, :last_name, :email, :mobile_phone, :status, :id, :upid, :image, :timezone], 
           :include => { :pets => { :only => [:name, :breed, :gender, :weight, :birthdate], :include => { :petphotos => { :only => [:id, :image] }}},
                         :addresses => { :only => [:line1, :line2, :locality] }
            } )

      # render json: {:person => @person, :clients => @clients, :pets => @pets }, :layout => false
      render json: 
           {:person => @person,
            :clients => @clients.to_json(:only => [:first_name, :last_name, :email, :mobile_phone, :status, :id, :upid, :image], 
                 :include => { :pets => { :only => [:id, :name, :breed, :gender, :weight, :birthdate], :include => { :petphotos => { :only => [:id, :image] }}},
                               :addresses => { :only => [:line1, :line2, :locality] }
                             } ),
            :invitations => @invitations.to_json
           }, :layout => false
      logger.debug "pro_mobile_user_updates end"
  end

    # refactor - 2013-05-06
    # updating DogWalker app to be similar to PetOwner app - store objects in localStorage
    #   person, address, clients, pets, dogwalks, report_cards
    # if the pro mobile user verified their email - status = "active mobile"
    #  find all Clients (people & pets) & related photos
    # no view or html - returns json 
    #  list of image file names on s3
    def pro_mobile_user_updates2
      logger.debug "pro_mobile_user_updates2 start"
      @person = Person.find_by_upid(params[:id])
      #@address = @person.addresses.last
      # @clients = []
      # @person.person_connections.each do |pc|
      #     #other_person = Person.find(pc.person_b_id)
      #     @other_person = Person.includes({:pets => :petphotos }, :addresses).find(pc.person_b_id)
      #     #logger.debug("other_person email = #{@other_person.email} and id = #{@other_person.id}")
      #     if pc.category.eql?('Dog Walker')
      #         #@clients << { other_person.email => other_person.id }
      #         @clients << @other_person
      #     end
      # end
      
      # the like also picks up Dog Walker Sample
      @clients = @person.peeps.where("person_connections.category like 'Dog Walker%'").includes({:pets => :petphotos }, :addresses)

      logger.debug("@clients.size = #{@clients.size}")

      @invitations = Invitation.select(:email).where(:requestor_email => @person.email, :status => 'invited')
      logger.debug("@invitations = " + @invitations.to_json)
      # a list of pet_ids where chistine is (f&f) caretaker
      #  ????
      #@pets = Caretaker.where(:person_id => @person.id).uniq.pluck(:pet_id)
      #logger.debug("@pets = " + @pets.to_s)
      #logger.debug "@pets.size = #{@pets.size}"
      #render json: {:person => @person, :clients => @clients, :pets => @pets }, :layout => false
      logger.debug "@clients = " + @clients.to_json(:only => [:first_name, :last_name, :email, :mobile_phone, :status, :id, :upid, :image, :timezone], 
           :include => { :pets => { :only => [:name, :breed, :gender, :weight, :birthdate], :include => { :petphotos => { :only => [:id, :image] }}},
                         :addresses => { :only => [:line1, :line2, :locality] }
      } )

      @pets = []
      #@caretaker_to_these_pets = Caretaker.where(:person_id => @person.id)
      
      @report_cards = Dogwalk.order("updated_at desc").where("person_id = ? AND stop IS NOT NULL AND status = 'active'", @person.id)
      @dogwalks = Dogwalk.order("updated_at desc").where("person_id = ? AND stop IS NULL AND status = 'active'", @person.id)
      

      # render json: {:person => @person, :clients => @clients, :pets => @pets }, :layout => false
      # render json: 
      #      {:person => @person,
      #       :clients => @clients.to_json(:only => [:first_name, :last_name, :email, :mobile_phone, :status, :id, :upid, :image], 
      #            :include => { :pets => { :only => [:id, :name, :breed, :gender, :weight, :birthdate], :include => { :petphotos => { :only => [:id, :image] }}},
      #                          :addresses => { :only => [:line1, :line2, :locality] }
      #                        } ),
      #       :invitations => @invitations.to_json
      #      }, :layout => false
           
       render json: {:person       => @person,
                     #:address      => @address,
                     :clients      => @clients,
                     :invitations  => @invitations,
                     #:pets         => @pets.to_json(:include => {:pet => {:include => :petphotos}}),
                     :pets         => @pets,              # uses as_json in models Caretaker and Pet
                     #:photos       => @photos, 
                     :report_cards => @report_cards,
                     :dogwalks     => @dogwalks
                    },
             :layout => false
           
        logger.debug "pro_mobile_user_updates2 end"
    end


  # called by PetOwner app - my_pet_pros.js
  def my_pet_pros 
      @person = Person.find(params[:person_id])
      @pro_connections = @person.person_connections.where(:category => ['Dog Walk Client', 'Groomer Client', 'Boarding Client', 'Veterinary Client'])
      @clients = []
      @pro_connections.each do |pc|
          @clients << Person.find(pc.person_b_id)
      end
      logger.debug("@clients.size = #{@clients.size}")

      render json: {:person => @person, :clients => @clients }, :layout => false
  end
  
  # called by a "pro" app to show one client and that client's pets
  def client_and_pets
      #@person = Person.includes(:addresses).find(params[:id])
      #@pets = @person.pets.includes(:petphotos)
      @person = Person.includes(:addresses, :pets => :petphotos).find(params[:id])
      #logger.debug("@pets[0].petphotos.size = #{@pets[0].petphotos.size}")
      #render json: {:person => @person, :pets => @pets }, :layout => false
      @address = @person.addresses.last
      
      render json: {:person => @person.as_json(:include => { :pets => { :include => :petphotos } } ), :address => @address}, :layout => false

      #render json: {:person => @person.as_json(:include => { :pets => { :include => :petphotos }, :addresses} ) }, :layout => false
      #render json: {:person => @person.as_json(:include => [:pets => { :include => {:petphotos} }, :addresses] ) }, :layout => false

      #render json: {:person => @person.as_json(:include => [:pets => { :include => :petphotos }, :addresses] ) }, :layout => false

  end
  
end






