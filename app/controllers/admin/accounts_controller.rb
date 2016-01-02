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

# Provides acounts administration in the admin section
class Admin::AccountsController < Admin::ApplicationController
  add_breadcrumb 'Account', :admin_accounts_path

  before_action :find_account, only: [:edit,
                                      :show,
                                      :update,
                                      :cancel,
                                      :confirm_cancel,
                                      :confirm_restore,
                                      :events,
                                      :restore,
                                      :users]

  authorize_resource

  def index
    @accounts = Account.includes(:plan).page(params[:page])
  end

  def create
    @account = Account.new(accounts_params.merge(card_token: 'dummy'))
    if @account.save
      StripeAccountCreateJob.perform_later @account.id
      AppEvent.success("Created account #{@account}", @account, current_user)
      logger.info { "Account '#{@account}' created - #{admin_account_url(@account)}" }
      redirect_to admin_account_path(@account),
                  notice: 'Account was successfully created.'
    else
      add_breadcrumb 'New', new_admin_account_path
      logger.debug { "Account create failed #{@account.inspect}" }
      render 'new'
    end
  end

  def edit
    add_breadcrumb 'Modifica', edit_admin_account_path(@account)
  end

  def new
    @account = Account.new
    add_breadcrumb 'Nuovo', new_admin_account_path
  end

  def show
  end

  def update
    if @account.update_attributes(accounts_params)
      StripeAccountUpdateJob.perform_later @account.id
      AppEvent.success("Updated account #{@account}", @account, current_user)
      logger.info { "Account '#{@account}' updated - #{admin_account_url(@account)}" }
      redirect_to admin_account_path(@account),
                  notice: 'Account Aggiornato con successo.'
    else
      add_breadcrumb 'Modifica', edit_admin_account_path(@account)
      logger.debug { "Account update failed #{@account.inspect}" }
      render 'edit'
    end
  end

  def events
    @app_events = @account.app_events.includes(:user).page(params[:page])
    add_breadcrumb 'Events', admin_account_events_path(@account)
  end

  def cancel
    if @account.cancel(cancel_params)
      StripeAccountCancelJob.perform_later @account.id
      AppEvent.info("Cancelled account #{@account}", @account, current_user)
      logger.info { "Account '#{@account}' cancelled - #{admin_account_url(@account)}" }
      redirect_to admin_account_path(@account), notice: 'Account cancellato con successo.'
    else
      @cancellation_categories = CancellationCategory.available_with_reasons
      add_breadcrumb 'Eliminazione', admin_account_cancel_path(@account)
      logger.debug { "Account cancel failed #{@account.inspect}" }
      render 'confirm_cancel', notice: 'Impossibie cancellare questo account.'
    end
  end

  def confirm_cancel
    add_breadcrumb 'Eliminazione', admin_account_cancel_path(@account)
    @cancellation_categories = CancellationCategory.available_with_reasons
  end

  def confirm_restore
    add_breadcrumb 'Ripristino', admin_account_restore_path(@account)
  end

  def restore
    if @account.restore
      StripeAccountRestoreJob.perform_later @account.id
      AppEvent.success("Restored account #{@account}", @account, current_user)
      logger.info { "Account '#{@account}' restored - #{admin_account_url(@account)}" }
      redirect_to admin_account_path(@account), notice: 'Account ripristinato con successo.'
    else
      logger.debug { "Account restore failed #{@account.inspect}" }
      add_breadcrumb 'Rispristino', admin_account_restore_path(@account)
      render 'confirm_restore', notice: 'Impossibile ripristinare questo account.'
    end
  end

  def users
    @user_permissions = @account.user_permissions.includes(:user).page(params[:page])
    add_breadcrumb 'Utenti', admin_account_users_path(@account)
  end

  private

  def find_account
    @account = Account.find(params[:account_id] || params[:id])
    add_breadcrumb @account, admin_account_path(@account)
  end

  def cancel_params
    params.require(:account).permit(:cancellation_category_id, :cancellation_message, :cancellation_reason_id)
  end

  def accounts_params
    params.require(:account).permit(:active,
                                    :address_city,
                                    :address_country,
                                    :address_line1,
                                    :address_line2,
                                    :address_state,
                                    :address_zip,
                                    :company_name,
                                    :custom_path,
                                    :email,
                                    :expires_at,
                                    :hostname,
                                    :plan_id,
                                    :paused_plan_id,
                                    :subdomain)
  end

  def set_sidebar_item
    @sidebar_item = :accounts
  end
end
