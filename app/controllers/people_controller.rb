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
  #  the user has just downloaded the app from itunes and installed it
  #  and they have started it for the first time
  #  create two objects Person and Device - Person object will be mostly blank
  def create_mobile
    @person = Person.new(params[:person])
    @person.first_name = @person.devices[0].name.split(/\b/)[0]
    @person.status = "new mobile"
    if @person.save
      render json: @person
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
     
     @person_a = Person.find_by_email(@invitation.requestor_email)
     #  create the person & device
     @person = Person.new
     @person.email = @invitation.email
     @person.timezone = params[:timezone]
     @person.status = "active mobile"
     puts "create_invited_mobile_user - next step is devices build "
     @person.devices.build(params[:device])
     #  create the person_connection
     @person.person_connections.build(:person_a_id => @person_a.id, :person_b_id => @person, 
         :category => @invitation.category, :invitation_id => @invitation.id, :status => 'active')
     #  create the caretaker(s) loop thru each pet
     puts "create_invited_mobile_user - next step is pets each "
     @person_a.pets.each do |pet|
         @person.caretakers.build(:pet_id => pet.id, :person_id => @person.id, :started_at => Time.now)
          # t.string :primary_role  t.string :secondary_role
     end 
     #  return person as json
     puts "create_invited_mobile_user - next step is person.save "
     if @person.save
       puts "create_invited_mobile_user - save - render end"
       render json: @person
     else
       puts "create_invited_mobile_user - save - error"
       render json: @person.errors, status: :unprocessable_entity
     end     
  end

  # PUT /people/1
  # PUT /people/1.json
  # do betters: 
  #    keep count of # of verify_email requests
  def update
    @person = Person.find(params[:id])
    # support for the mobile app "Verify My Email"
    #logger.debug("params[:person][:email] = " + params[:person][:email] + " status = " + @person.status)
    if params[:person][:email] && @person.status == "new mobile"
      @person.status = "verifying"
    end
    respond_to do |format|
      if @person.update_attributes(params[:person])
          if @person.status.eql?("verifying")
              UserMailer.verify_email_mobile_user(@person).deliver 
          end
          format.html { redirect_to @person, notice: 'Profile was saved.' }
          #format.json { head :no_content }
          format.json { render json: @person }
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
      #render html
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
  def mobile_user_updates
      @person = Person.find_by_upid(params[:id])
      render json: @person, :layout => false
  end

end
