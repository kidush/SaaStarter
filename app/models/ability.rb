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

# The users abilities
class Ability
  include CanCan::Ability

  # rubocop:disable Metrics/CyclomaticComplexity, PerceivedComplexity
  def initialize(user, account, section)
    # Don't set any permissions if the user isn't logged in
    return if user.nil?

    # Don't set any premissions if you're not a super admin in the admin section
    return if section == :admin && !user.super_admin?

    # Super Admin's can do anything
    can :manage, :all if user.super_admin?

    # Users can always manage themselves but cannot destroy themselves or remove permissions
    # These need to happen here as user stuff is outside of any particular account
    can :manage, User, id: user.id
    cannot :destroy, User, id: user.id

    # Find the permissions for the user/account
    if account
      permissions = user.user_permissions.find_by account: account
    else
      permissions = nil
    end

    # Don't set any permissions if the user doesn't have any for this account
    return if permissions.nil? && !user.super_admin?

    # Don't set any permissions if you're not a super or account admin in the settings section
    return if section == :settings && !(user.super_admin? || permissions.account_admin?)

    # Set the basic permissions
    can :manage, Account, user_permissions: { user_id: user.id, account_admin: true }
    can :manage, Invoice, account: { user_permissions: { user_id: user.id, account_admin: true } }
    can :manage, UserInvitation, account: { user_permissions: { user_id: user.id, account_admin: true } }
    can :manage, UserPermission, account: { user_permissions: { user_id: user.id, account_admin: true } }
    can :manage, UserPermission, user_id: user.id
    cannot :destroy, UserPermission, user_id: user.id unless user.super_admin
    can :index, :settings_dashboard if user.super_admin? || permissions.account_admin?
    can :index, :dashboard

    # Enforce plan restrictions against everyone (including Super Admin's)
    cannot :pause, Account, plan: { paused_plan: nil }
  end
  # rubocop:enable Metrics/CyclomaticComplexity, PerceivedComplexity
end
