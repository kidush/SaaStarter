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

# Migration to set all timestamps to not null. This isn't required if migrations
# are run from scratch but is required for existing installations
class FixTimestamps < ActiveRecord::Migration
  def up
    change_column :delayed_jobs, :updated_at, :datetime, null: false
    change_column :delayed_jobs, :created_at, :datetime, null: false
    change_column :users, :updated_at, :datetime, null: false
    change_column :users, :created_at, :datetime, null: false
    change_column :plans, :updated_at, :datetime, null: false
    change_column :plans, :created_at, :datetime, null: false
    change_column :accounts, :updated_at, :datetime, null: false
    change_column :accounts, :created_at, :datetime, null: false
    change_column :app_events, :updated_at, :datetime, null: false
    change_column :app_events, :created_at, :datetime, null: false
    change_column :user_permissions, :updated_at, :datetime, null: false
    change_column :user_permissions, :created_at, :datetime, null: false
    change_column :user_invitations, :updated_at, :datetime, null: false
    change_column :user_invitations, :created_at, :datetime, null: false
    change_column :cancellation_categories, :updated_at, :datetime, null: false
    change_column :cancellation_categories, :created_at, :datetime, null: false
    change_column :cancellation_reasons, :updated_at, :datetime, null: false
    change_column :cancellation_reasons, :created_at, :datetime, null: false
  end

  def down
    change_column :delayed_jobs, :updated_at, :datetime, null: true
    change_column :delayed_jobs, :created_at, :datetime, null: true
    change_column :users, :updated_at, :datetime, null: true
    change_column :users, :created_at, :datetime, null: true
    change_column :plans, :updated_at, :datetime, null: true
    change_column :plans, :created_at, :datetime, null: true
    change_column :accounts, :updated_at, :datetime, null: true
    change_column :accounts, :created_at, :datetime, null: true
    change_column :app_events, :updated_at, :datetime, null: true
    change_column :app_events, :created_at, :datetime, null: true
    change_column :user_permissions, :updated_at, :datetime, null: true
    change_column :user_permissions, :created_at, :datetime, null: true
    change_column :user_invitations, :updated_at, :datetime, null: true
    change_column :user_invitations, :created_at, :datetime, null: true
    change_column :cancellation_categories, :updated_at, :datetime, null: true
    change_column :cancellation_categories, :created_at, :datetime, null: true
    change_column :cancellation_reasons, :updated_at, :datetime, null: true
    change_column :cancellation_reasons, :created_at, :datetime, null: true
  end
end
