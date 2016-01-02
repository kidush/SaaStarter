# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

Stripe.api_key = "sk_test_cyYRQb30KTPRooCgb0f74mdz"
STRIPE_PUBLIC_KEY = "pk_test_Wy8ZSC0n6N1ZvJqTKdugpvoT"
