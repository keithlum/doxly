class InvitationMailer < ApplicationMailer
  default from: 'invitation@doxly.com'

  def invitation_email(user, organization_user)
    @user = user
    @organization_user = organization_user
    @url  = 'http://doxly.com/accept-ivitation/' + @organization_user.invitation_token
    mail(to: @user.email, subject: 'Invitation to join in our organization.')
  end
end
