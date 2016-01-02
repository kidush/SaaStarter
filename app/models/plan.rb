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

require 'money'

# Plan model
class Plan < ActiveRecord::Base
  has_many :accounts
  has_many :paused_accounts, class_name: 'Account', foreign_key: :paused_plan_id
  has_many :paused_plans, class_name: 'Plan', foreign_key: :paused_plan_id

  before_destroy do |plan|
    if Account.where('plan_id = ? or paused_plan_id= ?', plan.id, plan.id).count > 0
      errors.add(:base, 'plan is in use')
      false
    end
  end

  before_update do |plan|
    plan.errors.add :paused_plan_id, 'cannot use a plan as its own paused plan' if plan.id == plan.paused_plan_id
    plan.errors.add :currency, 'cannot change the currency' if plan.currency_changed?
    plan.errors.add :interval_count, 'cannot change the interval count' if plan.interval_count_changed?
    plan.errors.add :interval, 'cannot change the interval' if plan.interval_changed?
    plan.errors.add :amount, 'cannot change the amount' if plan.amount_changed?
    plan.errors.add :trial_period_days, 'cannot change the trial period days' if plan.trial_period_days_changed?

    false if plan.errors.count > 0
  end

  belongs_to :paused_plan, class_name: 'Plan'

  scope :available, -> { where('active = ? AND public = ?', true, true).order('amount DESC, name ASC') }
  scope :available_for_currency,
        lambda { |for_currency|
          available.where('currency = ?', for_currency).order('amount DESC, name ASC')
        }

  validates :active, inclusion: { in: [true, false] }, presence: false, allow_blank: false
  validates :allow_custom_path, inclusion: { in: [true, false] }, presence: false, allow_blank: false
  validates :allow_hostname, inclusion: { in: [true, false] }, presence: false, allow_blank: false
  validates :allow_subdomain, inclusion: { in: [true, false] }, presence: false, allow_blank: false
  validates :amount,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, integer_only: true }
  validates :currency,
            inclusion: { in: Money::Currency.all.map(&:iso_code) },
            presence: true
  validates :interval,
            inclusion: { in: %w( day week month year ) },
            presence: true
  validates :interval_count,
            presence: true,
            numericality: { greater_than_or_equal_to: 1, integer_only: true }
  validates :label, length: { maximum: 30 }, presence: false
  validates :max_users,
            presence: true,
            numericality: { greater_than_or_equal_to: 1, integer_only: true }
  validates :name, length: { maximum: 150 }, presence: true
  validates :public, inclusion: { in: [true, false] }, presence: false, allow_blank: false
  validates :statement_description, length: { maximum: 150 }
  validates :stripe_id, length: { maximum: 80 }, presence: true
  validates :trial_period_days, presence: true
  validates :trial_period_days,
            numericality: { greater_than_or_equal_to: 0, integer_only: true },
            if: :require_card_upfront
  validates :trial_period_days,
            numericality: { greater_than_or_equal_to: 1, integer_only: true },
            unless: :require_card_upfront

  def to_s
    name
  end
end
