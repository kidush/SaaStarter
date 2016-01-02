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

# View helpers common across the entire application
module ApplicationHelper
  def currency_list
    require 'money'

    Money::Currency.all.map { |c| ["#{c.iso_code}: #{c.name}", "#{c.iso_code}"] }
  end

  # Render the plan price formatted nicely
  def formatted_plan_price(plan, free_text = nil)
    return free_text if plan.amount == 0 && !free_text.nil?

    period = ''
    period = number_with_precision(plan.interval_count, precision: 0) + ' ' if plan.interval_count > 1
    period += plan.interval

    amount = Money.new(plan.amount, plan.currency).format

    "#{amount} / #{period}"
  end

  # Render alerts for missing ENV variables
  def missing_env_notice(var)
    return unless ENV[var].nil?
    "<div class=\"alert alert-danger\"><strong>#{var}</strong> environment variable is not set</div>".html_safe
  end

  # Render the errors for the model
  def render_errors(model)
    html = ''
    model.errors.full_messages.each do |message|
      html = html + '<div class="alert alert-danger">' + html_escape(message) + '</div>'
    end
    html.html_safe
  end
end
