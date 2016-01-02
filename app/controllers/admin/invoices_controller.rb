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

# Provides invoices administration in the admin section
class Admin::InvoicesController < Admin::ApplicationController
  before_action :find_account
  before_action :find_invoice, only: [:show]

  authorize_resource

  def index
    if @account
      @invoices = @account.invoices.page(params[:page])
      @nav_item = 'Account'
    else
      @invoices = Invoice.page(params[:page])
    end
  end

  def show
  end

  private

  def find_account
    if params[:account_id]
      @account = Account.find(params[:account_id])
      @sidebar_item = :accounts
      add_breadcrumb 'Account', admin_accounts_path
      add_breadcrumb @account, admin_account_path(@account)
      add_breadcrumb 'Nuovi utenti', admin_account_user_invitations_path(@account)
    else
      add_breadcrumb 'Fatture', :admin_invoices_path
    end
  end

  def find_invoice
    @invoice = Invoice.find(params[:invoice_id] || params[:id])
    add_breadcrumb @invoice, admin_invoice_path(@invoice)
  end

  def set_sidebar_item
    @sidebar_item = :invoices
  end
end
