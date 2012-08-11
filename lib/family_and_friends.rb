module FamilyAndFriends
    
    # this method does not need to know about other models
    # it just knows how to create a person_connection
    def create_peep_connection(a_id, b_id, cat, invite_id)
        puts "debug point in module FamilyAndFriends.create_peep_connection"
        @pc = PersonConnection.create(:person_a_id => a_id, :person_b_id => b_id, :category => cat, :invitation_id => invite_id)        
        @pc = PersonConnection.create(:person_a_id => b_id, :person_b_id => a_id, :category => cat, :invitation_id => invite_id)        
    end

    def check_peep_connection
        # look in session for invitation
        if session[:i_id]
            @invitation = Invitation.find(session[:i_id])
            # if exists, and not a sign up request, then create connection 
            # create the person_connection
            if !@invitation.email.eql?(@invitation.requestor_email)
                @requestor = Person.find_by_email(@invitation.requestor_email)
                create_peep_connection(current_user.person.id, @requestor.id, @invitation.category, @invitation.id)
            end
            # complete the invitation
            @invitation.status = 'accepted'
            @invitation.save!
            session[:i_id] = nil
        end
    end
    
end
