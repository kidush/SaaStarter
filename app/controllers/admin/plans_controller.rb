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
class Admin::PlansController < Admin::ApplicationController
  add_breadcrumb 'Piani', :admin_plans_path

  before_action :find_plan, only: [:account,
                                   :destroy,
                                   :edit,
                                   :show,
                                   :update,
                                   :accounts,
                                   :paused_plans]

  authorize_resource

  def index
    @plans = Plan.page(params[:page])
  end

  def accounts
    add_breadcrumb 'Modifica', admin_plan_accounts_path(@plan)
    @accounts =
      Account.includes(:plan).where('plan_id = ? or paused_plan_id = ?', @plan.id, @plan.id).page(params[:page])
  end

  def create
    @plan = Plan.new(plans_create_params)
    if @plan.save
      StripePlanCreateJob.perform_later @plan.id
      AppEvent.success("Created plan #{@plan}", nil, current_user)
      logger.info { "Plan '#{@plan}' created - #{admin_plan_url(@plan)}" }
      redirect_to admin_plan_path(@plan),
                  notice: 'Piano creato con successo.'
    else
      add_breadcrumb 'Nuovo', new_admin_plan_path
      logger.debug { "Plan create failed #{@plan}" }
      render 'new'
    end
  end

  def edit
    add_breadcrumb 'Modifica', edit_admin_plan_path(@plan)
  end

  def new
    add_breadcrumb 'New', new_admin_plan_path
    @plan = Plan.new
  end

  def show
  end

  def update
    if @plan.update_attributes(plans_update_params)
      StripePlanUpdateJob.perform_later @plan.id
      logger.info { "Plan '#{@plan}' updated - #{admin_plan_url(@plan)}" }
      AppEvent.success("Updated plan #{@plan}", nil, current_user)
      redirect_to admin_plan_path(@plan),
                  notice: 'Piano aggiornato con successo.'
    else
      add_breadcrumb 'Modifica', edit_admin_plan_path(@plan)
      logger.debug { "Plan update failed #{@plan.inspect}" }
      render 'edit'
    end
  end

  def destroy
    if @plan.destroy
      StripePlanDeleteJob.perform_later(@plan.stripe_id)
      AppEvent.info("Deleted plan #{@plan}", nil, current_user)
      logger.info { "Plan '#{@plan}' destroyed - #{admin_plan_url(@plan)}" }
      redirect_to admin_plans_path,
                  notice: 'Piano rimosso con successo.'
    else
      logger.debug { "Plan destroy failed #{@plan.inspect}" }
      redirect_to admin_plan_path(@plan),
                  alert: 'Impossibile rimuovere il piano.'
    end
  end

  private

  def find_plan
    @plan = Plan.find(params[:plan_id] || params[:id])
    add_breadcrumb @plan, admin_plan_path(@plan)
  end

  def plans_create_params
    params.require(:plan).permit(:active,
                                 :allow_custom_path,
                                 :allow_hostname,
                                 :allow_subdomain,
                                 :amount,
                                 :currency,
                                 :interval,
                                 :interval_count,
                                 :label,
                                 :max_users,
                                 :name,
                                 :paused_plan_id,
                                 :public,
                                 :require_card_upfront,
                                 :statement_description,
                                 :stripe_id,
                                 :trial_period_days)
  end

  def plans_update_params
    params.require(:plan).permit(:active,
                                 :allow_custom_path,
                                 :allow_hostname,
                                 :allow_subdomain,
                                 :max_users,
                                 :label,
                                 :name,
                                 :paused_plan_id,
                                 :public,
                                 :require_card_upfront,
                                 :statement_description)
  end

  def set_sidebar_item
    @sidebar_item = :plans
  end
end
