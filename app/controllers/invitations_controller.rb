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
end
