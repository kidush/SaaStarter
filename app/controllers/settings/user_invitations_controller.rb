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

# Allows the account admin to manage user invitations in the settings
class Settings::UserInvitationsController < Settings::ApplicationController
  add_breadcrumb 'Nuovi Utenti', :settings_user_invitations_path

  before_action :find_user_invitation, only: [:destroy, :edit, :show, :update]

  authorize_resource

  def index
    @user_invitations = current_account.user_invitations.page(params[:page])
  end

  def create
    @user_invitation = current_account.user_invitations.build(user_invitation_params)
    if @user_invitation.save
      UserMailer.user_invitation(@user_invitation).deliver_later
      AppEvent.success("Created user invitation #{@user_invitation}", current_account, current_user)
      # rubocop:disable Metrics/LineLength
      logger.info { "User invitation '#{@user_invitation}' created - #{admin_account_user_invitation_url(@account, @user_invitation)}" }
      # rubocop:enable Metrics/LineLength
      redirect_to settings_user_invitation_path(@user_invitation),
                  notice: 'Nuovo utente invitato con successo.'
    else
      add_breadcrumb 'Nuovo', new_settings_user_invitation_path
      logger.debug { "User invitation update failed #{@user_invitation.inspect}" }
      render 'new'
    end
  end

  def edit
    add_breadcrumb 'Modifica', edit_settings_user_invitation_path(@user_invitation)
  end

  def new
    add_breadcrumb 'Nuovo', new_settings_user_invitation_path
    @user_invitation = current_account.user_invitations.build
  end

  def show
  end

  def update
    p = user_invitation_params
    if @user_invitation.update_attributes(p)
      UserMailer.user_invitation(@user_invitation).deliver_later
      AppEvent.success("Updated user invitation #{@user_invitation}", current_account, current_user)
      # rubocop:disable Metrics/LineLength
      logger.info { "User invitation '#{@user_invitation}' updated - #{admin_account_user_invitation_url(@account, @user_invitation)}" }
      # rubocop:enable Metrics/LineLength
      redirect_to settings_user_invitation_path(@user_invitation),
                  notice: 'Invito nuovo utente aggiornato.'
    else
      add_breadcrumb 'Modifica', edit_settings_user_invitation_path(@user_invitation)
      logger.debug { "User invitation update failed #{@user_invitation.inspect}" }
      render 'edit'
    end
  end

  def destroy
    if @user_invitation.destroy
      AppEvent.info("Deleted user #{@user_invitation}", current_account, current_user)
      # rubocop:disable Metrics/LineLength
      logger.info { "User invitation '#{@user_invitation}' destroyed - #{admin_account_user_invitation_url(@account, @user_invitation)}" }
      # rubocop:enable Metrics/LineLength
      redirect_to settings_user_invitations_path, notice: 'Invito nuovo utente rimosso.'
    else
      logger.debug { "User invitation destroy failed #{@user_invitation.inspect}" }
      redirect_to settings_user_invitation_path(@user), alert: 'Impossibile rimuovere questo invito.'
    end
  end

  def accounts
    @user_permissions = @user.user_permissions.includes(:account).page(params[:page])
  end

  private

  def find_user_invitation
    @user_invitation = current_account.user_invitations.find(params[:id])
    add_breadcrumb @user_invitation, settings_user_invitation_path(@user_invitation)
  end

  def user_invitation_params
    params.require(:user_invitation).permit(:email, :first_name, :last_name)
  end

  def set_sidebar_item
    @sidebar_item = :settings_user_invitations
  end
end
