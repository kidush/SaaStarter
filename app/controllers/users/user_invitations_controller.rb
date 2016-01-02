# Encoding: utf-8

# Copyright (c) 2014-2015, Richard Buggy <rich@buggy.id.au>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# The User Invitations controller implements accepting user invitations
class Users::UserInvitationsController < ApplicationController
  # Skip authentication and authorization for the marketing controller.
  # We want anonymous users to be able to access it.
  skip_before_action :authenticate_user!, only: [:show]
  skip_authorization_check

  layout 'marketing'

  def show
    @user_invitation = UserInvitation.new(invite_code: params[:invite_code])
  end

  def accept
    user_invitation = UserInvitation.find_by(invite_code: params[:invite_code])
    if user_invitation
      user_permission = user_invitation.account.user_permissions.build(user: current_user)
      if user_permission.save
        UserMailer.welcome(current_user).deliver_later
        user_invitation.destroy
        @account = user_permission.account
        logger.info { "User invitation accepted #{params[:invite_code]}" }
      else
        AppEvent.alert("Could not create new user permission for #{current_user} / #{@account}", @account, nil)
        logger.warn { "User invitation accept failed #{params[:invite_code]}" }
      end
    else
      logger.debug { "User invitation not found #{params[:invite_code]}" }
      redirect_to new_user_invitation_path(invite_code: params[:invite_code]), alert: 'Invalid invite code'
    end
  end
end
