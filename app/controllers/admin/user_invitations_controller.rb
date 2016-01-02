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

# Provides plans administration in the admin section
class Admin::UserInvitationsController < Admin::ApplicationController
  before_action :find_account
  before_action :find_user_invitation, only: [:destroy, :edit, :show, :update]

  authorize_resource

  def index
    if @account
      @user_invitations = @account.user_invitations.page(params[:page])
    else
      @user_invitations = UserInvitation.includes(:account).page(params[:page])
    end
  end

  def create
    @user_invitation = @account.user_invitations.build(user_invitation_params)
    if @user_invitation.save
      UserMailer.user_invitation(@user_invitation).deliver_later
      AppEvent.success("Created user invitation #{@user_invitation}", @account, current_user)
      # rubocop:disable Metrics/LineLength
      logger.info { "User invitation '#{@user_invitation}' created - #{admin_account_user_invitation_url(@account, @user_invitation)}" }
      # rubocop:enable Metrics/LineLength
      redirect_to admin_account_user_invitation_path(@account, @user_invitation),
                  notice: 'Nuovo utente invitato con successo.'
    else
      add_breadcrumb 'Nuovo', new_admin_account_user_invitation_path(@account)
      logger.debug { "User invitation create failed #{@user_invitation.inspect}" }
      render 'new'
    end
  end

  def edit
    add_breadcrumb 'Modifica', edit_admin_account_user_invitation_path(@account, @user_invitation)
  end

  def new
    add_breadcrumb 'Nuovo', new_admin_account_user_invitation_path(@account)
    @user_invitation = @account.user_invitations.build
  end

  def show
  end

  def update
    p = user_invitation_params
    if @user_invitation.update_attributes(p)
      UserMailer.user_invitation(@user_invitation).deliver_later
      AppEvent.success("Updated user invitation #{@user_invitation}", @user_invitation.account, current_user)
      # rubocop:disable Metrics/LineLength
      logger.info { "User invitation '#{@user_invitation}' updated - #{admin_account_user_invitation_url(@account, @user_invitation)}" }
      # rubocop:enable Metrics/LineLength
      redirect_to admin_account_user_invitation_path(@user_invitation.account, @user_invitation),
                  notice: 'Nuovo utente aggiornato con successo.'
    else
      add_breadcrumb 'Modifica', edit_admin_account_user_invitation_path(@account, @user_invitation)
      render 'edit'
    end
  end

  def destroy
    account = @user_invitation.account
    if @user_invitation.destroy
      AppEvent.info("Deleted user #{@user_invitation}", @user_invitation.account, current_user)
      # rubocop:disable Metrics/LineLength
      logger.info { "User invitation '#{@user_invitation}' destroyed - #{admin_account_user_invitation_url(@account, @user_invitation)}" }
      # rubocop:enable Metrics/LineLength
      redirect_to admin_account_user_invitations_path(account), notice: 'Nuovo utente rimosso con successo.'
    else
      logger.debug { "User invitation destroy failed #{@user_invitation.inspect}" }
      redirect_to admin_account_user_invitation_path(account, @user), alert: 'Impossibile rimuovo invito nuovo utente.'
    end
  end

  def accounts
    add_breadcrumb 'Modifica', edit_admin_account_user_invitation_accounts_path(@accounts, @user_invitation)
    @user_permissions = @user.user_permissions.includes(:account).page(params[:page])
  end

  private

  def find_account
    if params[:account_id]
      @account = Account.find(params[:account_id]) if params[:account_id]
      @sidebar_item = :accounts
      add_breadcrumb 'Account', admin_accounts_path
      add_breadcrumb @account, admin_account_path(@account)
      add_breadcrumb 'Nuovo utente', admin_account_user_invitations_path(@account)
    else
      add_breadcrumb 'Nuovo utente', admin_user_invitations_path
    end
  end

  def find_user_invitation
    @user_invitation = UserInvitation.find(params[:user_invitation_id] || params[:id])
    add_breadcrumb @user_invitation, admin_account_user_invitation_path(@account, @user_invitation)
  end

  def user_invitation_params
    params.require(:user_invitation).permit(:email, :first_name, :last_name)
  end

  def set_sidebar_item
    @sidebar_item = :user_invitations
  end
end
