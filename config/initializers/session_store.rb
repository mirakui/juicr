# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_juicr_session',
  :secret      => 'c5e3c4e5d561f4d4bf62991a499e25192e5f6c413443c93fe372d2a9bfbb60f1c237248f34f6e3535e4d3095482676f952e632367751be8e066521212424c42a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
