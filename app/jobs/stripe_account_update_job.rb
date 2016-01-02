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

# ActiveJob to update a Stripe account
class StripeAccountUpdateJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    # Don't use Account.find(id) as it assumes id is the obsificated ID
    account = Account.find_by(id: id)

    customer = Stripe::Customer.retrieve(account.stripe_customer_id)
    customer.card = account.card_token if account.card_token? && account.card_token != 'dummy'
    customer.description = account.company_name
    customer.email = account.email
    customer.save

    subscription = customer.subscriptions.retrieve(account.stripe_subscription_id)
    current_plan = account.plan_stripe_id
    current_plan = account.paused_plan_stripe_id unless account.paused_plan_stripe_id.nil?
    if subscription.plan.id != current_plan
      subscription.plan = current_plan
      subscription.save
    end

    account.card_token = 'dummy'
    account.expires_at = Time.zone.at(subscription.current_period_end)
    account.save

    card = customer.cards.retrieve(customer.default_card)
    account.card_brand = card.brand
    account.card_last4 = card.last4
    account.card_exp = "#{card.exp_month}/#{card.exp_year}"
    account.save!
  end
end
