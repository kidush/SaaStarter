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

# Provides cancellation categories administration in the admin section
class Admin::CancellationReasonsController < Admin::ApplicationController
  before_action :find_cancellation_category
  before_action :find_cancellation_reason, only: [:edit, :show, :update]

  authorize_resource

  def index
    @cancellation_reasons = @cancellation_category.cancellation_reasons.page(params[:page])
  end

  def create
    @cancellation_reason = @cancellation_category.cancellation_reasons.build(cancellation_reason_params)
    if @cancellation_reason.save
      AppEvent.success("Created cancellation category #{@cancellation_reason}", nil, current_user)
      # rubocop:disable Metrics/LineLength
      logger.info { "Cancellation reason '#{@cancellation_reason}' created - #{admin_cancellation_category_cancellation_reason_url(@cancellation_category, @cancellation_reason)}" }
      # rubocop:enable Metrics/LineLength
      redirect_to admin_cancellation_category_cancellation_reason_path(@cancellation_category, @cancellation_reason),
                  notice: 'Motivo cancellazione creato con successo.'
    else
      add_breadcrumb 'Nuovo', new_admin_cancellation_category_cancellation_reason_path(@cancellation_category)
      logger.debug { "Cancellation reason create failed #{@cancellation_reason.inspect}" }
      render 'new'
    end
  end

  def edit
    add_breadcrumb 'Modifica', edit_admin_cancellation_category_cancellation_reason_path(@cancellation_category,
                                                                                     @cancellation_reason)
  end

  def new
    add_breadcrumb 'Nuco', new_admin_cancellation_category_cancellation_reason_path(@cancellation_category)
    @cancellation_reason = @cancellation_category.cancellation_reasons.build
  end

  def show
  end

  def update
    if @cancellation_reason.update_attributes(cancellation_reason_params)
      AppEvent.success("Updated cancellation category #{@cancellation_reason}", nil, current_user)
      # rubocop:disable Metrics/LineLength
      logger.info { "Cancellation reason '#{@cancellation_reason}' updated - #{admin_cancellation_category_cancellation_reason_url(@cancellation_category, @cancellation_reason)}" }
      # rubocop:enable Metrics/LineLength
      redirect_to admin_cancellation_category_cancellation_reason_path(@cancellation_category, @cancellation_reason),
                  notice: 'Motivo cancellazione aggiornato con successo.'
    else
      add_breadcrumb 'Modifica', edit_admin_cancellation_category_cancellation_reason_path(@cancellation_category,
                                                                                       @cancellation_reason)
      logger.debug { "Cancellation reason update #{@cancellation_reason.inspect}" }
      render 'edit'
    end
  end

  private

  def find_cancellation_category
    @cancellation_category = CancellationCategory.find(params[:cancellation_category_id])
    add_breadcrumb 'Categorie cancellazione', admin_cancellation_categories_path
    add_breadcrumb @cancellation_category, admin_cancellation_category_path(@cancellation_category)
    add_breadcrumb 'Motivi cancellazione',
                   admin_cancellation_category_cancellation_reasons_path(@cancellation_category)
  end

  def find_cancellation_reason
    @cancellation_reason = @cancellation_category.cancellation_reasons.find(params[:id])
  end

  def cancellation_reason_params
    params.require(:cancellation_reason).permit(:active,
                                                :allow_message,
                                                :name,
                                                :require_message)
  end

  def set_sidebar_item
    @sidebar_item = :cancellation_categories
  end
end
