class InvitationsController < ApplicationController
    include FamilyAndFriends
    
    # GET /invitations
    # GET /invitations.json
    def index
        @invitations = Invitation.all

        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @invitations }
        end
    end

    # GET /invitations/1
    # GET /invitations/1.json
    def show
        @invitation = Invitation.find(params[:id])

        respond_to do |format|
          format.html # show.html.erb
          format.json { render json: @invitation }
        end
    end

    # GET /invitations/new
    # GET /invitations/new.json
    def new
        @invitation = Invitation.new

        respond_to do |format|
            format.html # new.html.erb
            format.json { render json: @invitation }
        end
    end

    # GET /invitations/1/edit
    def edit
        @invitation = Invitation.find(params[:id])
    end

    # POST /invitations
    # POST /invitations.json
    # two basic scenarios 
    # 1. a person inviting themselves (aka sign up)
    # 2. a person inviting family or friends
    def create
        @invitation = Invitation.new(params[:invitation])
        @invitation.ip_address = request.remote_ip.to_s
        @invitation.verify_email_sent_at = Time.zone.now

        if current_user   # 2. person inviting family or friend
            @invitation.requestor_email = current_user.email
        else              # 1. person inviting themselves (sign up)
            @invitation.requestor_email = params[:invitation][:email]
        end

        # what about the scenario where a user forgets that they already signed up?

        @known_user_being_invited = User.where(:email => params[:invitation][:email], :status => 'active').first
        if @known_user_being_invited
            @invitation.existing_user = 'true' 
        else 
            @invitation.existing_user = 'false'
        end

        # check for duplicate
        @duplicate = Invitation.where(:email => params[:invitation][:email], :requestor_email => @invitation.requestor_email).first
        if @duplicate
            @duplicate.request_count += 1
            @duplicate.save
            UserMailer.invitation_confirmation(current_user, @duplicate).deliver if @duplicate.request_count < 3
            redirect_to person_path(current_user.person.id), :notice => "Duplicate Invite"
        elsif @invitation.save
            # does the person being invited already exist in epet?
            #@invite_to_known_user = User.find_by_email(@invitation.email)
            #UserMailer.invitation_confirmation(current_user, @invitation, @invite_to_known_user).deliver
            Spawnling.new do
                UserMailer.invitation_confirmation(current_user, @invitation).deliver
            end
            if current_user
                redirect_to person_path(current_user.person.id), :notice => "Invite sent."
            else
                redirect_to root_url, :notice => "Check your email inbox for instructions"
            end
        else
            render "new"
        end
    end

    # do betters: 
    #   check invitation.verify_email_sent_at
    #   check ip addresses
    def verify_email 
        @invitation = Invitation.find_by_verify_email_token!(params[:id])
        if @invitation
            @invitation.status = 'email verified'
            @invitation.save!
            # store the invitation id in the session for use later in creating the person_connection
            # after the user has logged in or created their user profile
            session[:i_id] = @invitation.id
            if current_user    #user has a cookie or is logged in 
                # Carla was invited to join Christine's F&F - Carla already a "stay logged in user of epet"
                redirect_to person_path(current_user.person)
            elsif @invitation.existing_user.eql?("true") 
                # redirect to the login screen 
                redirect_to :login
            else
                # redirect to new user screen
                redirect_to new_user_url(:email => @invitation.email)
            end
        end
    end


    # PUT /invitations/1
    # PUT /invitations/1.json
    def update
        #@invitation = Invitation.find(params[:id])
        @invitation = Invitation.find_by_verify_email_token!(params[:id])
        if @invitation
            @invitation.status = 'email verified'
            @invitation.save!
            if current_user
                # ????
            else 
                redirect_to new_user_url(:email => @invitation.email)
            end
        end
    end

    # DELETE /invitations/1
    # DELETE /invitations/1.json
    def destroy
        @invitation = Invitation.find(params[:id])
        @invitation.destroy

        respond_to do |format|
          format.html { redirect_to invitations_url }
          format.json { head :no_content }
        end
    end
  
    def family_friends_mobile 
        @person = Person.find(params[:person_id])
        @partners = @person.person_connections.where(:category => 'Spouse-Partner', :status => 'active')
        @famandfrnds = @person.person_connections.where(:category => ['Family', 'Friend', ''], :status => 'active')

        # should this be person_id or email??
        @invitations = Invitation.where(:requestor_email => @person.email, :status => 'invited')

        render :layout => false
    end
    # 2013-07-10  replacing above
    def family_friends_accept_invitation
        
    end


    def clients_dogwalk
        @person = Person.find(params[:id])

        @pro_connections = @person.person_connections.where(:category => 'Dog Walk Client', :status => 'active')
        @clients = []
        @pro_connections.each do |pc|
            @clients << Person.find(pc.person_b_id)
        end
        logger.debug("@clients.size = #{@clients.size}")

        @invitations = Invitation.where(:requestor_email => @person.email, :status => 'invited')
        render json: {:person => @person, :clients => @clients, :invitations => @invitations }, :layout => false    
    end

    def create_mobile 
        logger.debug("create_mobile start")

        @invitation = Invitation.new(params[:invitation])
        # work around: setting the device's unique user id (uuid) to ip_address
        @invitation.verify_email_sent_at = Time.zone.now

        @known_user_being_invited = Person.where(:email => params[:invitation][:email], :status => 'active mobile').first
        if @known_user_being_invited
            @invitation.existing_user = 'true'
        else 
            @invitation.existing_user = 'false'
        end

        # check for duplicate
        @duplicate = Invitation.where(:email => params[:invitation][:email], :requestor_email => @invitation.requestor_email).first
        if @duplicate
            @duplicate.request_count += 1
            @duplicate.save
            if @duplicate.request_count < 3
                Spawnling.new do
                    UserMailer.mobile_invitation_confirmation(@invitation.requestor_email, @duplicate).deliver
                end
            end
            #redirect_to person_path(current_user.person.id), :notice => "Duplicate Invite"
        elsif @invitation.save
            # UserMailer.mobile_invitation_confirmation(@invitation.requestor_email, @invitation).deliver
            Spawnling.new do
                UserMailer.mobile_invitation_confirmation(@invitation.requestor_email, @invitation).deliver
                logger.info("UserMailer finished")
            end
        end
        @invited = Invitation.where(:requestor_email => @invitation.requestor_email, :status => 'invited')
        render json: @invited, :layout => false
    end

    def create_invitation_from_pet_owner
        logger.debug("create_invitation_from_pet_owner start")

        @invitation = Invitation.new(params[:invitation])
        # work around: setting the device's unique user id (uuid) to ip_address
        @invitation.verify_email_sent_at = Time.zone.now

        @known_user_being_invited = Person.where(:email => params[:invitation][:invitee_email], :status => 'active mobile').first
        if @known_user_being_invited
            @invitation.existing_user = 'true'
        else 
            @invitation.existing_user = 'false'
        end

        # check for duplicate
        @duplicate = Invitation.where(:email => params[:invitation][:invitee_email], :requestor_email => @invitation.invitor_email).first
        if @duplicate
            @duplicate.request_count += 1
            @duplicate.save
            if @duplicate.request_count < 3
                Spawnling.new do
                    UserMailer.mobile_invitation_confirmation(@invitation.invitor_email, @duplicate).deliver
                end
            end
            #redirect_to person_path(current_user.person.id), :notice => "Duplicate Invite"
        elsif @invitation.save
            Spawnling.new do
                #UserMailer.mobile_invitation_confirmation(@invitation.invitor_email, @invitation).deliver
                UserMailer.create_invitation_from_pet_owner(@invitation.invitor_email, @invitation).deliver
                logger.info("UserMailer finished")
            end
        end
        @invitations = Invitation.where(:invitor_email => @invitation.invitor_email, :status => 'invited')
        render json: @invitations, :layout => false
    end

    # general notes about invitations - over many months have evolved this functionality
    #  on 2013-04-23 started creating private methods to handle common functions
    #  basic flow:
    #  1. put the form fields into a new Invitation obj
    #  2. determine if the person being invited is already known to epetfolio - known_user or @invitation.existing_user
    #  3. determine if this invitation is a duplicate - don't want one user annoying or stalking another 
    #  4. return json of all such outstanding invitations
    
    # similar to above (create_mobile)
    # should rename "create_mobile" to pet_owner_inviting_friend_or_fam
    # dogwalker entered client's email address - form fields

    # sample test params:
    # Parameters: {"invitation"=>{"invitor_email"=>"tuetest1250@foo.com", "invitor_upid"=>"-vNzvTQ5NMqkjt7cZCGwbA", 
    #              "category"=>"Dog Walker", "invitee_email"=>"testclient1317@foo.com"}}
    # added cols to Invitations table
    def dogwalker_inviting_client
        logger.debug("dogwalker_inviting_client start")
        @invitation = Invitation.new(params[:invitation])
        # work around: setting the device's unique user id (uuid) to ip_address
        @invitation.verify_email_sent_at = Time.zone.now

        # is the person being invited already in epetfolio?
        #@known_user_being_invited = Person.where(:email => params[:invitation][:email], :status => 'active mobile').first
        @known_user_being_invited = Person.where(:email => params[:invitation][:invitee_email], :status => 'active mobile').first
        if @known_user_being_invited
            @invitation.existing_user = 'true'
        else 
            @invitation.existing_user = 'false'
        end
        # check for duplicate invitation - want to avoid badgering
        #@duplicate = Invitation.where(:email => params[:invitation][:email], :requestor_email => @invitation.requestor_email).first
        @duplicate = Invitation.where(:invitee_email => params[:invitation][:invitee_email],
                                      :invitor_email => params[:invitation][:invitor_email]).first
        if @duplicate
            @duplicate.request_count += 1
            @duplicate.save
            if (@duplicate.request_count < 3)
                Spawnling.new do
                    UserMailer.dogwalker_inviting_client(@invitation.requestor_email, @duplicate).deliver
                end
            end
            #redirect_to person_path(current_user.person.id), :notice => "Duplicate Invite"
        elsif @invitation.save
            Spawnling.new do
                UserMailer.dogwalker_inviting_client(@invitation.requestor_email, @invitation).deliver
            end
        end
        # return value is all the open invitations
        #@invitations = Invitation.where(:requestor_email => @invitation.requestor_email, :status => 'invited')
        @invitations = Invitation.where(:invitor_email => params[:invitation][:invitor_email], :status => 'invited')
        render json: @invitations, :layout => false
    end

    # added 2013-04-23 - pet owner is inviting a dog walker - opposite of above
    def pet_owner_inviting_dogwalker
        logger.debug("pet_owner_inviting_dogwalker start")
        @invitation = Invitation.new(params[:invitation])
        # work around: setting the device's unique user id (uuid) to ip_address
        @invitation.verify_email_sent_at = Time.zone.now
        
        #@invitation.existing_user = known_user(params[:invitation][:email])
        @known_user_being_invited = Person.where(:email => params[:invitation][:invitee_email], :status => 'active mobile').first
        if @known_user_being_invited
            @invitation.existing_user = 'true'
        else 
            @invitation.existing_user = 'false'
        end
        logger.debug("pet_owner_inviting_dogwalker debug a : @invitation.existing_user = " + @invitation.existing_user)
        # check for duplicate invitation - want to avoid badgering
        @duplicate = Invitation.where(:invitee_email => params[:invitation][:invitee_email], :invitor_email => @invitation.invitor_email).first
        if @duplicate
            @duplicate.request_count += 1
            @duplicate.save
            if (@duplicate.request_count < 3)
                Spawnling.new do
                    UserMailer.pet_owner_inviting_dogwalker(@invitation.invitor_email, @duplicate).deliver
                end
            end 
        elsif @invitation.save
            logger.debug("pet_owner_inviting_dogwalker debug b : @invitation.save")
            Spawnling.new do
                UserMailer.pet_owner_inviting_dogwalker(@invitation.invitor_email, @invitation).deliver
                logger.info("pet_owner_inviting_dogwalker debug b1 : UserMailer finished")
            end
        end
        #logger.debug("pet_owner_inviting_dogwalker end")
        @invitations = Invitation.where(:invitor_email => @invitation.invitor_email, :status => 'invited')
        render json: @invitations, :layout => false
    end

    # takes a unique invitation token ( params[:verify_email_token] ) and updates the row's status 
    def accept_invitation_existing_user
        #  find and update the invitation
        @invitation = Invitation.find_by_verify_email_token(params[:token])
        @invitation.update_attributes(:status => "accepted")
        #  find the two people
        @invitor = Person.where(:email => @invitation.requestor_email, :status => 'active mobile').order('updated_at DESC').first!
        @invitee = Person.where(:email => @invitation.email, :status => 'active mobile').order('updated_at DESC').first!
        #  create the first person_connection 
        @invitor.person_connections.build(:person_a_id => self, :person_b_id => @invitee.id,
          :category => @invitation.category, :invitation_id => @invitation.id, :status => 'active')
        #  create the second (reverse) person_connection 
        @invitee.person_connections.build(:person_a_id => self, :person_b_id => @invitor.id,
          :category => @invitation.category, :invitation_id => @invitation.id, :status => 'active')
        if @invitor.save && @invitee.save 
        #          redirect_to "PetOwner://epetfolio/%{token}"
            redirect_to "PetOwner://epetfolio/accepted_invite_known_user"
        else 
            logger.error("Error accepting f&f invitation")
        end
    end

    #  from their email inbox, the user has clicked on "Accept Invite" link from a f&f 
    #  check if the invitation has already been accepted
    #  check if the request is from a mobile device or a laptop 
    #     (should click the link from the mobile device where the epet app is installed)
    #  expand this method to handle dog walkers accepting invite
    def preliminary_accept_invite 
        logger.debug("request.fullpath = " + request.fullpath)
        #  is request from mobile device?
        if request.user_agent =~ /Mobile|webOS/
            #  find the invitation
            @invitation = Invitation.find_by_verify_email_token(params[:token])
            if @invitation.status.eql?('invited')
                # good
                if request.fullpath =~ /dogwalker_accepting_pet_owner_invitation/ 
                    redirect_to "DogWalker://epetfolio/#{params[:token]}"
                else 
                    redirect_to "PetOwner://epetfolio/#{params[:token]}"
                end
            elsif @invitation.status.eql?('accepted')
                # bad dup
                if request.fullpath =~ /dogwalker_accepting_pet_owner_invitation/ 
                    redirect_to "DogWalker://epetfolio/duplicate_accept_invitation"
                else 
                    redirect_to "PetOwner://epetfolio/duplicate_accept_invitation"
                end
            end
        else 
            # render view preliminary_accept_invite - "Please accept the invite from the mobile device where.."
        end
    end

    # refactored 2013-07-04
    # updates Invitation
    # do relationships need to be created?
    # create relationships if necessary
    def accept_invite3
        #  find the invitation
        @invitation = Invitation.find_by_verify_email_token(params[:token])
        duplicate_accept_invite = false

        #  has the invitation already been accepted?
        if @invitation.status.eql?('accepted')
            duplicate_accept_invite = true
            @invitation.accept_count += 1
            @invitation.save
        else
            @invitation.update_attributes(:status => 'accepted')
        end
        # do we know the invitee?
        @person = People.where("email => ? AND status => ?", @invitation.invitee_email, 'active_mobile').first
        if @person
           create_relationships(@invitation)
        end
    end

    # two types of relationships to create 
    # 1. person to person -- person_connections table
    # 2. person to pet    -- caretakers table
    # assumptions: Invitation has been accepted, both people are "active mobile"
    #   if the invitee is a PetPro then also assume that the invitor has at least one pet
    def create_relationships(invitation)
        @invitor = Person.where("email = ? AND status = 'active mobile'", invitation.invitor_email).first
        @invitee = Person.where("email = ? AND status = 'active mobile'", invitation.invitee_email).first
        logger.debug("debug point alpha")
        @invitor.person_connections.build(:person_a_id => @invitor.id, :person_b_id => @invitee.id,
            :category => invitation.category, :invitation_id => invitation.id, :status => 'active')
        logger.debug("debug point beta")

        #  create the second (reverse) person_connection 
        @invitee.person_connections.build(:person_a_id => @invitee.id, :person_b_id => @invitor.id,
            :category => @invitation.category, :invitation_id => @invitation.id, :status => 'active')
        logger.debug("debug point gamma")

        # add caretaker row for each pet owned by the invitor
        @invitor.caretakers.each do |ct|
            if ct.primary_role.eql?('Owner')
                if @invitation.category.eql?('Spouse-Partner')
                    p_role = 'Owner'
                else
                    p_role = @invitation.category
                end
                @invitee.caretakers.build(:pet_id => ct.pet_id, :primary_role => p_role, :status => 'active', :started_at => Time.now)
            end
            logger.debug("debug point delta")
        end
        @invitor.save && @invitee.save
        
    end

    # refactored 2013-06-20
    # just updates Invitation status
    def accept_invite2
        #  find the invitation
        @invitation = Invitation.find_by_verify_email_token(params[:token])
        duplicate_accept_invite = false

        #  has the invitation already been accepted?
        if @invitation.status.eql?('accepted')
            duplicate_accept_invite = true
            @invitation.accept_count += 1
            @invitation.save
        else
            if @invitation.accept_count.blank?
                @invitation.accept_count = 1
            end
            @invitation.update_attributes(:status => 'accepted')
        end
        # do we know the invitee?  is used in the view to customize the msg 
        @person = Person.where("email = ? AND status = 'active_mobile'", @invitation.invitee_email).first

    end

    # POST request from accepting_invite_form
    # takes a unique invitation token ( params[:verify_email_token] ) and upid
    # updates the Invitation row's status 
    # updates the Person row
    # creates the person_connections
    # creates the caretakers (pet connections)
    # returns Person json obj
    def accept_invite
        #  find the invitation
        @invitation = Invitation.find_by_verify_email_token(params[:token])
        duplicate_accept_invite = false

        #  has the invitation already been accepted?
        if @invitation.status.eql?('accepted')
            duplicate_accept_invite = true
        else
            @invitation.update_attributes(:status => 'accepted')
            #  find the two people
            @invitor = Person.where(:email => @invitation.requestor_email, :status => 'active mobile').order('updated_at DESC').first!

            # when the invitee installs and starts the app, they get a upid, but we may not yet know their email
            @invitee = Person.find_by_upid(params[:upid])
            if @invitee.email.blank?
                @invitee.email = @invitation.email    # this person's email is now verified
            end
            if !@invitee.status.eql?('active mobile')
                @invitee.status = 'active mobile'
            end
            logger.debug("debug point alpha - @invitor.id = " + @invitor.id.to_s + "  @invitee.id = " + @invitee.id.to_s)
            #  create the first person_connection 
#            @invitor.person_connections.build(:person_a_id => self, :person_b_id => @invitee.id,
#                :category => @invitation.category, :invitation_id => @invitation.id, :status => 'active')
            @invitor.person_connections.build(:person_a_id => @invitor.id, :person_b_id => @invitee.id,
                :category => @invitation.category, :invitation_id => @invitation.id, :status => 'active')
            logger.debug("debug point beta")
            #  create the second (reverse) person_connection 
            @invitee.person_connections.build(:person_a_id => @invitee.id, :person_b_id => @invitor.id,
                :category => @invitation.category, :invitation_id => @invitation.id, :status => 'active')
            logger.debug("debug point delta")
            # add caretaker row for each pet owned by the invitor
            @invitor.caretakers.each do |ct|
                if ct.primary_role.eql?('Owner')
                    if @invitation.category.eql?('Spouse-Partner')
                        p_role = 'Owner'
                    elsif @invitation.category.eql?('Family') || @invitation.category.eql?('Friend')
                        p_role = @invitation.category
                    else 
                        p_role = 'Other'
                    end
                    @invitee.caretakers.build(:pet_id => ct.pet_id, :primary_role => p_role, :status => 'active', :started_at => Time.now)
                end
            end
            @invitor.save && @invitee.save
        end

        if duplicate_accept_invite
            #render json: "duplicate_accept_invite"
            render :json => '{duplicate_accept_invite: true}'
        elsif @invitee
            if @invitee.personas =~ /Pro_Dog_Walker/
                # return to the DogWalker app all the dog walker clients including the one just created
                logger.debug("accept_invite - invitee is Pro_Dog_Walker - returing @clients as json")
                @clients = @invitee.peeps.where("person_connections.category = 'Dog Walker'").includes({:pets => :petphotos }, :addresses)
                render json: {:clients => @clients }, :layout => false
            elsif @invitor.personas =~ /Pro_Dog_Walker/
                logger.debug("accept_invite - invitor is Pro_Dog_Walker - returing @pet_pros as json")
                @pet_pros = @invitee.peeps.where("person_connections.category = 'Dog Walker'").includes({:pets => :petphotos }, :addresses)
                render json: {:clients => @clients }, :layout => false
            else 
                logger.debug("accept_invite - returing @invitee as json")
                render json: @invitee
            end
        else
            logger.error("Error accepting f&f invitation")
        end
    end

    # added 2013-02-17 - dog walker app - clients screen - "Clients Invited" list
    def dogwalker_invited
        #@invitations = Invitation.invited_clients_email(params[:email]).select(:email)
        @invitations = Invitation.invitees(params[:email]).select(:email)
        logger.debug("@invitations.to_json = " + @invitations.to_json)
        render json: {:invitations => @invitations }, :layout => false
    end

    # added 2013-06-21 - refactored verify_my_email
    # ajax POST JSON from mobile app - never html 
    # create an invitation
    # update person
    # send email
    # Parameters: {"id"=>"N_22r4YMEGAUDG2vqjRRbg", "email_to_verify"=>"KDJFSLKDJ@foo.com"}
    def verify_email2
        @person = Person.find_by_upid(params[:id])

        @invitation                      = Invitation.new(:email => params[:email_to_verify], )
        @invitation.status               = 'verifying'
        @invitation.verify_email_sent_at = Time.zone.now
        #  before create a token is generated 
        @invitation.save!

        @person.status = 'verifying'
        @person.comments = @invitation.verify_email_token
        @person.save!
        Spawnling.new do
            UserMailer.verify_email_mobile_user(@invitation).deliver
            logger.debug("after spawn - invitations_controller - verify_email_mobile_user delivered")
        end
        render json: { :email => @invitation.email }
    end

    # user clicks link in their email - HTTP browser response
    def verifying_email
        @invitation = Invitation.where("verify_email_token = ? and status = 'verifying'", params[:id]).first
        @person = Person.where("comments = ? and status = 'verifying'", @invitation.verify_email_token).first
        if @invitation && @person
            @person.email = @invitation.email
            @person.status = 'active mobile'
            @invitation.status = 'verified'
            if @person.save && @invitation.save
                render 'email_verified'
            end
        else
            render 'email_not_verified'
        end
    end
end
















