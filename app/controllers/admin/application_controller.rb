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

# Base class for all application controllers
class Admin::ApplicationController < ApplicationController
  add_breadcrumb 'Admin', :admin_root_path

  # Return the ability model. It needs to know about the user and the account.
  def current_ability
    Ability.new(current_user, current_account, :admin)
  end

  private

  def set_nav_item
    @nav_item = 'Dashboard'
  end

  def set_sidebar_menu
    @sidebar_menu = {
      dashboard: { title: 'Dashboard', url: admin_root_path },
      accounts: { title: 'Account', url: admin_accounts_path },
      cancellation_categories: { title: 'Cateogrie Cancellazione', url: admin_cancellation_categories_path },
      events: { title: 'Eventi', url: admin_events_path },
      invoices: { title: 'Fatture', url: admin_invoices_path },
      jobs: { title: 'Cronologia Eventi', url: admin_jobs_path },
      plans: { title: 'Piani', url: admin_plans_path },
      users: { title: 'Utenti', url: admin_users_path },
      user_invitations: { title: 'Nuovi Utenti', url: admin_user_invitations_path }
    }
  end

  def set_sidebar_item
    @sidebar_item = :dashboard
  end
end
