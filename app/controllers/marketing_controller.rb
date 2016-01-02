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

# The Marketing controller implements all of the marketing pages
class MarketingController < ApplicationController
  # Skip authentication and authorization for the marketing controller.
  # We want anonymous users to be able to access it.
  skip_before_action :authenticate_user!, only: [:pricing, :register, :signup]
  skip_authorization_check

  layout 'marketing'

  def index
    if current_user.super_admin?
      redirect_to admin_root_path
    else
      account = current_account
      account = current_user.accounts.first if account.nil?
      if account
        redirect_to tenant_root_path(path: account.to_param)
      else
        redirect_to users_path
      end
    end
  end

  def pricing
    currency = params[:currency] || 'USD'
    @plans = Plan.available_for_currency(currency)
  end

  def register
    @plan = Plan.available.find_by(id: params[:account][:plan_id])

    if @plan.nil?
      logger.debug "Select plan is not available #{params[:account][:plan_id]}"
      return redirect_to pricing_path, alert: 'Invalid plan.'
    end

    @account = Account.new(accounts_params, active: true)
    if @account.register(current_user)
      StripeAccountCreateJob.perform_later @account.id
      AppEvent.success("Created account #{@account}", @account, nil)
      logger.info { "Account '#{@account}' created - #{admin_account_url(@account)}" }
      redirect_to new_user_session_path,
                  notice: 'Success. Please log in to continue.'
    else
      logger.debug { "Account create failed #{@account.inspect}" }
      render 'signup'
    end
  end

  def signup
    @plan = Plan.available.find_by(id: params[:plan_id])
    if @plan.nil?
      logger.debug { "Plan not found #{params[:plan_id]}" }
      redirect_to pricing_path, alert: 'Invalid plan.'
    else
      @account = Account.new(plan: @plan,
                             address_country: 'us')
      @account.users.build
    end
  end

  private

  def accounts_params
    params.require(:account).permit(:address_city,
                                    :address_country,
                                    :address_line1,
                                    :address_line2,
                                    :address_state,
                                    :address_zip,
                                    :company_name,
                                    :plan_id,
                                    :card_token,
                                    users_attributes: [:first_name,
                                                       :last_name,
                                                       :email,
                                                       :password,
                                                       :password_confirmation])
  end
end
