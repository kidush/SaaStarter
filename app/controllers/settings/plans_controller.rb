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

# Allows the account admin to manage plans in the settings
class Settings::PlansController < Settings::ApplicationController
  add_breadcrumb 'Piano', :settings_plan_path

  before_action do
    authorize!(params[:action], @account || Account)
  end

  def edit
    add_breadcrumb 'Modifica', edit_settings_plan_path

    @plan = Plan.available.find(params[:id])
    @account.plan_id = @plan.id
  end

  def show
    if params[:currency]
      currency = params[:currency]
    else
      currency = @account.plan_currency
    end

    @plans = Plan.available_for_currency(currency)
  end

  def update
    @plan = Plan.available.find(params[:account][:plan_id])
    if @account.update_attributes(plan_id: @plan.id)
      StripeAccountUpdateJob.perform_later @account.id
      AppEvent.success('Change to plan ' + @plan.to_s, current_account, current_user)
      logger.info { "Plan for '#{@account}' updated to '#{@plan}' - #{admin_account_url(@account)}" }
      redirect_to settings_root_path, notice: 'Piano aggiornato con successo.'
    else
      add_breadcrumb 'Modifica', edit_settings_plan_path
      logger.debug { "Plan update failed #{@account.inspect}" }
      render 'edit'
    end
  end

  def cancel
    add_breadcrumb 'Cancella', cancel_settings_plan_path
    @cancellation_categories = CancellationCategory.available_with_reasons
  end

  def pause
    add_breadcrumb 'Pause', pause_settings_plan_path
    if @account.pause
      StripeAccountUpdateJob.perform_later @account.id
      AppEvent.warning('Paused the account', current_account, current_user)
      logger.info { "Account '#{@account}' paused - #{admin_account_url(@account)}" }
      redirect_to root_path, notice: 'Account limitato.'
    else
      flash[:alert] = 'Impossibile limitare questo account.'
      logger.debug { "Account pause failed #{@account.inspect}" }
      render 'cancel'
    end
  end

  def destroy
    if @account.cancel(cancel_params)
      StripeAccountCancelJob.perform_later @account.id
      AppEvent.alert('Cancelled the account', current_account, current_user)
      logger.info { "Account '#{@account}' destroyed - #{admin_account_url(@account)}" }
      redirect_to root_path, notice: 'Account cancellato.'
    else
      add_breadcrumb 'Cancella', cancel_settings_plan_path
      flash[:alert] = 'Impossibile cancellare questo account.'
      @cancellation_categories = CancellationCategory.available_with_reasons
      logger.debug { "Account destroy failed #{@account.inspect}" }
      render 'cancel'
    end
  end

  private

  def set_sidebar_item
    @sidebar_item = :settings_plan
  end

  def cancel_params
    params.require(:account).permit(:cancellation_category_id, :cancellation_message, :cancellation_reason_id)
  end
end
