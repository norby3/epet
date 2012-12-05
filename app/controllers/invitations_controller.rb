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
            UserMailer.invitation_confirmation(current_user, @invitation).deliver
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
          UserMailer.mobile_invitation_confirmation(@invitation.requestor_email, @duplicate).deliver if @duplicate.request_count < 3
          #redirect_to person_path(current_user.person.id), :notice => "Duplicate Invite"
      elsif @invitation.save
          UserMailer.mobile_invitation_confirmation(@invitation.requestor_email, @invitation).deliver
      end

      head :created
      logger.debug("create_mobile end")
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

    # POST request from accepting_invite_form
    # takes a unique invitation token ( params[:verify_email_token] ) and upid
    # updates the Invitation row's status 
    # updates the Person row
    # creates the person_connections
    # returns Person json obj
    def accept_invite
        #  find and update the invitation
        @invitation = Invitation.find_by_verify_email_token(params[:token])
        @invitation.update_attributes(:status => "accepted")
        #  find the two people
        @invitor = Person.where(:email => @invitation.requestor_email, :status => 'active mobile').order('updated_at DESC').first!
        @invitee = Person.find_by_upid(params[:upid])
        if @invitee.email.blank?
            @invitee.email = @invitation.email    # this person's email is now verified
        end
        if !@invitee.status.eql?('active mobile')
            @invitee.status = 'active mobile'
        end
        #  create the first person_connection 
        @invitor.person_connections.build(:person_a_id => self, :person_b_id => @invitee.id,
            :category => @invitation.category, :invitation_id => @invitation.id, :status => 'active')
        #  create the second (reverse) person_connection 
        @invitee.person_connections.build(:person_a_id => self, :person_b_id => @invitor.id,
            :category => @invitation.category, :invitation_id => @invitation.id, :status => 'active')

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

        if @invitor.save && @invitee.save 
            render json: @invitee
        else 
            logger.error("Error accepting f&f invitation")
        end
    end

end




