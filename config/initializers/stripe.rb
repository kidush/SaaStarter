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

Stripe.api_key = "sk_test_cyYRQb30KTPRooCgb0f74mdz"
STRIPE_PUBLIC_KEY = "pk_test_Wy8ZSC0n6N1ZvJqTKdugpvoT"

# StripeEvent.configure do |events|
#
#   events.subscribe 'account.application.deauthorized' do |event|
#     # I don't really care about this object but I do want to log it as an alert
#     LogEvent.create(level: 'alert',
#                     message: "Account application deauthorized [STRIPE: #{event.id}]")
#   end
#
#   events.subscribe 'charge.succeeded' do |event|
#     StripeGateway.delay.charge_event(event.id)
#   end
#
#   events.subscribe 'charge.failed' do |event|
#     StripeGateway.delay.charge_event(event.id)
#   end
#
#   events.subscribe 'charge.refunded' do |event|
#     StripeGateway.delay.charge_event(event.id)
#   end
#
#   events.subscribe 'charge.captured' do |event|
#     StripeGateway.delay.charge_event(event.id)
#   end
#
#   events.subscribe 'charge.updated' do |event|
#     StripeGateway.delay.charge_event(event.id)
#   end
#
#   events.subscribe 'charge.dispute.created' do |event|
#     StripeGateway.delay.dispute_event(event.id)
#   end
#
#   events.subscribe 'charge.dispute.updated' do |event|
#     StripeGateway.delay.dispute_event(event.id)
#   end
#
#   events.subscribe 'charge.dispute.closed' do |event|
#     StripeGateway.delay.dispute_event(event.id)
#   end
#
#   # Are we really handling a surprise delete correctly?
#   events.subscribe 'customer.deleted' do |event|
#     StripeGateway.delay.customer_event(event.id)
#   end
#
#   # Should I have code here to cancel an account?
#   events.subscribe 'customer.subscription.deleted' do |event|
#     StripeGateway.delay.subscription_event(event.id)
#   end
#
#   # This should really trigger a trial ending email?
#   events.subscribe 'customer.subscription.trial_will_end' do |event|
#     StripeGateway.delay.subscription_event(event.id)
#   end
#
#   events.subscribe 'invoice.created' do |event|
#     StripeGateway.delay.invoice_event(event.id)
#   end
#
#   events.subscribe 'invoice.updated' do |event|
#     StripeGateway.delay.invoice_event(event.id)
#   end
#
#   events.subscribe 'invoice.payment_succeeded' do |event|
#     StripeGateway.delay.invoice_event(event.id)
#   end
#
#   events.subscribe 'invoice.payment_failed' do |event|
#     StripeGateway.delay.invoice_event(event.id)
#   end
#
#   events.subscribe 'invoiceitem.created' do |event|
#     StripeGateway.delay.invoiceitem_event(event.id)
#   end
#
#   events.subscribe 'invoiceitem.updated' do |event|
#     StripeGateway.delay.invoiceitem_event(event.id)
#   end
#
#   events.subscribe 'invoiceitem.deleted' do |event|
#     StripeGateway.delay.invoiceitem_event(event.id)
#   end
#
#   events.all do |event|
#     LogEvent.create(level: 'success',
#                     message: "Stripe event #{event.type} [STRIPE: ##{event.id}]")
#   end
# end
