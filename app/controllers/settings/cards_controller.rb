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

# Allows the account admin to manage cards in the settings
class Settings::CardsController < Settings::ApplicationController
  add_breadcrumb 'Carta di Credito', :settings_card_path

  before_action :find_account, only: [:show, :edit, :update]

  before_action do
    authorize!(params[:action], @account || Account)
  end

  def show
  end

  def edit
    add_breadcrumb 'Modifica', edit_settings_card_path
    @account.card_token = nil
  end

  def update
    if @account.update_attributes(accounts_params)
      StripeAccountUpdateJob.perform_later @account.id
      AppEvent.success('Updated credit card', current_account, current_user)
      logger.info { "Card for '#{@account}' updated - #{admin_account_url(@account)}" }
      redirect_to settings_root_path,
                  notice: 'Carta di Credito aggiornata.'
    else
      add_breadcrumb 'Modifica', edit_settings_card_path
      @account.card_token = nil
      logger.debug { "Card update failed #{@account.inspect}" }
      render 'edit'
    end
  end

  private

  def set_sidebar_item
    @sidebar_item = :settings_card
  end

  def find_account
    @account = current_account
  end

  def accounts_params
    params.require(:account).permit(:card_token)
  end
end
